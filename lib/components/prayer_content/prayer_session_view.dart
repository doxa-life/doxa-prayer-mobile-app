import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:doxa_prayer_mobile_app/components/misc/triangle_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart' as intl;

import '../../l10n/app_localizations.dart';
import '../../layouts/page_scaffold.dart';
import '../../models/prayer_content.dart';
import '../../router.dart';
import '../../services/crash_reporting_service.dart';
import '../../services/identity_service.dart';
import '../../services/prayer_content_service.dart';
import '../../services/prayer_history_service.dart';
import '../../services/prayer_stats_service.dart';
import '../../services/thank_you_verse_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/cached_data_builder.dart';
import 'people_group_of_the_day_view.dart';
import 'praying_now_banner.dart';
import 'prayer_content_skeleton.dart';
import 'prayer_content_view.dart';
import 'prayer_thank_you_modal.dart';
import '../misc/hyphenated_text.dart';

const _minimumDurationInSeconds = 5;

/// How often a running session re-reports itself, and for how long. The server
/// treats a session's most recent report as its "last seen" time, so these pings
/// are what keep a live prayer visible in the "praying now" count. Mirrors the
/// web prayer page's cadence.
const _sessionPingInterval = Duration(seconds: 60);
const _sessionPingMaxAge = Duration(minutes: 15);

/// Renders the prayer content for a single people group [slug] on a given date,
/// with day navigation, the Amen action, and prayer-session tracking.
///
/// Used both by the Pray tab ([PrayScreen]) and the standalone deep-link screen.
/// [isActive] reports whether this view is the currently visible prayer surface
/// — it drives session start/stop (the Pray tab tracks `path == '/pray'`; the
/// standalone screen is always active while shown). The session and Amen posts
/// are keyed on [slug], so deep-linked prayers count for the right group.
class PrayerSessionView extends StatefulWidget {
  const PrayerSessionView({
    super.key,
    required this.slug,
    required this.language,
    required this.isActive,
    this.initialDate,
  });

  final String slug;
  final String language;
  final bool Function() isActive;
  final DateTime? initialDate;

  @override
  State<PrayerSessionView> createState() => _PrayerSessionViewState();
}

class _PrayerSessionViewState extends State<PrayerSessionView>
    with WidgetsBindingObserver {
  late DateTime _date;
  DateTime? _campaignStartDate;
  DateTime? _openedAt;
  String? _sessionId;
  Timer? _sessionOpenTimer;
  Timer? _sessionPingTimer;
  bool _submitting = false;
  bool _amenFired = false;
  bool _sessionActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appRouter.routerDelegate.addListener(_onRouteChanged);
    _date = widget.initialDate ?? DateTime.now();
    if (widget.isActive()) {
      _startSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    if (_sessionActive) {
      _endSession();
    }
    _cancelSessionPings();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log('App Lifecycle State: $state', name: 'pray_screen');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_sessionActive) {
        _endSession();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (widget.isActive() && !_sessionActive) {
        _startSession();
      }
    }
  }

  void _onRouteChanged() {
    final active = widget.isActive();
    if (active && !_sessionActive) {
      _startSession();
    } else if (!active && _sessionActive) {
      _endSession();
    }
  }

  void _startSession() {
    _openedAt = DateTime.now();
    // Generated up front, not at the end: every report a session makes upserts
    // on this id, so the open report, the pings and the final Amen all land on
    // one row rather than creating several.
    _sessionId = _generateId();
    _amenFired = false;
    _sessionActive = true;
    _scheduleSessionPings();
    // Refresh the praying-now count on every session start. This is the only
    // thing that moves the number: the Pray tab sits in an IndexedStack, so the
    // banner is never disposed and cannot refetch on mount. Fires on first open,
    // on app resume, and whenever the tab becomes current.
    unawaited(refreshPrayingNow());
    developer.log('Session started at: $_openedAt', name: 'pray_screen');
  }

  void _endSession() {
    _sessionActive = false;
    _cancelSessionPings();
    if (!_amenFired) {
      _amenFired = true;
      _recordAmenInBackground();
    }
  }

  /// Reports the session as it runs, so it shows up in the "praying now" count
  /// for as long as the user is actually here.
  ///
  /// The first report waits out [_minimumDurationInSeconds] so that merely
  /// glancing at the screen doesn't register as a prayer session — the same
  /// threshold the end-of-session record already applies.
  void _scheduleSessionPings() {
    _cancelSessionPings();
    _sessionOpenTimer = Timer(
      const Duration(seconds: _minimumDurationInSeconds),
      () {
        _postSessionPing();
        _sessionPingTimer = Timer.periodic(_sessionPingInterval, (timer) {
          final openedAt = _openedAt;
          // Stop reporting well after anyone is plausibly still praying, rather
          // than pinging forever on a screen left open.
          if (openedAt != null &&
              DateTime.now().difference(openedAt) > _sessionPingMaxAge) {
            timer.cancel();
            return;
          }
          _postSessionPing();
        });
      },
    );
  }

  void _cancelSessionPings() {
    _sessionOpenTimer?.cancel();
    _sessionOpenTimer = null;
    _sessionPingTimer?.cancel();
    _sessionPingTimer = null;
  }

  /// One "still here" report. Best-effort and silent: a dropped ping only means
  /// this session is briefly missing from a count.
  void _postSessionPing() {
    final openedAt = _openedAt;
    final sessionId = _sessionId;
    if (openedAt == null || sessionId == null || !_sessionActive) return;
    final now = DateTime.now();
    final report = PrayerSessionReport(
      sessionId: sessionId,
      trackingId: identityController.value?.trackingId ?? '',
      duration: now.difference(openedAt).inSeconds,
      timestamp: now.toUtc().toIso8601String(),
    );
    final slug = widget.slug;
    final date = _date;
    unawaited(
      postPrayerSession(slug: slug, date: date, report: report).catchError((
        Object e,
        StackTrace s,
      ) {
        developer.log(
          'prayer session ping failed',
          name: 'pray_screen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _recordAmenInBackground() {
    final openedAt = _openedAt;
    if (openedAt == null) return;
    final now = DateTime.now();
    final duration = now.difference(openedAt).inSeconds;
    if (duration <= _minimumDurationInSeconds) return;
    final timestamp = now.toUtc().toIso8601String();
    final report = PrayerSessionReport(
      sessionId: _sessionId ?? _generateId(),
      trackingId: identityController.value?.trackingId ?? '',
      duration: duration,
      timestamp: timestamp,
    );
    final slug = widget.slug;
    final date = _date;
    Future(() async {
      try {
        await postPrayerSession(slug: slug, date: date, report: report);
        await recordPrayer(
          PrayerRecord(
            slug: slug,
            durationSeconds: duration,
            timestamp: timestamp,
            openedAtTimestamp: openedAt.toUtc().toIso8601String(),
          ),
        );
      } catch (e, s) {
        // Best-effort background record; never surfaces to the user.
        reportError(e, s, reason: 'prayer session record failed (background)');
      }
    });
  }

  Future<PrayerContentResponse> _load({bool forceRefresh = false}) =>
      fetchPrayerContent(
        slug: widget.slug,
        date: _date,
        language: widget.language,
        forceRefresh: forceRefresh,
      );

  /// Repaints for the new [_date]. The load itself is driven by
  /// [CachedDataBuilder] keying on the date, so stepping back to a day already
  /// read shows it immediately, with no skeleton.
  void _showCurrentDate() {
    setState(() {
      if (_sessionActive) {
        // Stepping to another day is a new prayer session, not a continuation —
        // a fresh id keeps the two days on separate rows, as they are on the web
        // where changing day is a full page navigation.
        _openedAt = DateTime.now();
        _sessionId = _generateId();
        _scheduleSessionPings();
      }
    });
  }

  /// Date-only value (midnight local), for day-boundary comparisons.
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _canGoNext => _dateOnly(_date).isBefore(_dateOnly(DateTime.now()));

  bool get _canGoPrevious {
    final start = _campaignStartDate;
    return start == null || _dateOnly(_date).isAfter(start);
  }

  void _goToPreviousDay() {
    if (!_canGoPrevious) return;
    _date = _date.subtract(const Duration(days: 1));
    _showCurrentDate();
  }

  void _goToNextDay() {
    if (!_canGoNext) return;
    _date = _date.add(const Duration(days: 1));
    _showCurrentDate();
  }

  /// Capture the campaign start date from a resolved response so the previous
  /// arrow can be bounded. Deferred past the current build frame to avoid
  /// calling setState during the FutureBuilder build.
  void _captureStartDate(String? raw) {
    if (raw == null) return;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return;
    final start = _dateOnly(parsed);
    if (_campaignStartDate == start) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _campaignStartDate = start);
    });
  }

  String _generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    final rand = Random().nextInt(0x7fffffff).toRadixString(16);
    return '$ms-$rand';
  }

  /// The intro `people_group` block — the deep-linked/selected group, whose full
  /// detail card is rendered below the Amen button. Returns null when no such
  /// block carries people-group data.
  PrayerContentBlock? _selectedGroupBlock(PrayerContentResponse data) {
    for (final block in data.content) {
      if (block.type == PrayerContentBlockType.peopleGroup &&
          block.peopleGroupData != null) {
        return block;
      }
    }
    return null;
  }

  Future<void> _onAmen() async {
    if (_submitting || _amenFired) return;
    final openedAt = _openedAt;
    if (openedAt == null) return;
    _amenFired = true;
    _sessionActive = false;
    _cancelSessionPings();
    setState(() => _submitting = true);
    final now = DateTime.now();
    final duration = now.difference(openedAt).inSeconds;
    final timestamp = now.toUtc().toIso8601String();
    final report = PrayerSessionReport(
      sessionId: _sessionId ?? _generateId(),
      trackingId: identityController.value?.trackingId ?? '',
      duration: duration,
      timestamp: timestamp,
      // Only the explicit Amen raises an analytics event, matching the web page
      // — the pings a running session makes are not each a prayer.
      trackEvent: 'prayer_logged',
    );
    try {
      await postPrayerSession(slug: widget.slug, date: _date, report: report);
      await recordPrayer(
        PrayerRecord(
          slug: widget.slug,
          durationSeconds: duration,
          timestamp: timestamp,
          openedAtTimestamp: openedAt.toUtc().toIso8601String(),
        ),
      );
    } catch (error, stackTrace) {
      // Recording the prayer is best-effort; failures must not interrupt the
      // user's experience. Log for local dev and report as a non-fatal.
      developer.log(
        'Failed to record prayer session',
        name: 'prayer_session_view',
        error: error,
        stackTrace: stackTrace,
      );
      reportError(error, stackTrace, reason: 'prayer session record failed');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;
    // Announce the outcome for screen-reader users, since the visual
    // confirmation (the thank-you modal) isn't spoken automatically.
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppLocalizations.of(context)!.prayerRecordedAnnouncement,
      Directionality.of(context),
    );
    // Each "Amen" advances the rotation, so a returning user gets a new verse.
    final verse = await nextThankYouVerse(
      Localizations.localeOf(context).languageCode,
    );
    if (!mounted) return;
    await showPrayerThankYouModal(context, verse: verse);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _DateNavigator(
            date: _date,
            canGoPrevious: _canGoPrevious,
            canGoNext: _canGoNext,
            onPrevious: _goToPreviousDay,
            onNext: _goToNextDay,
          ),
          Expanded(
            child: CachedDataBuilder<PrayerContentResponse>(
              cacheKey: prayerContentCacheKey(
                slug: widget.slug,
                date: _date,
                language: widget.language,
              ),
              fetch: _load,
              loading: (context) => const PrayerContentSkeleton(),
              error: (context, retry) => PageContainer(
                child: _ErrorView(
                  message: l10n.couldNotLoadPrayerContent,
                  onRetry: retry,
                ),
              ),
              builder: (context, data) {
                _captureStartDate(data.globalStartDate);
                if (!data.hasContent || data.content.isEmpty) {
                  return PageContainer(
                    child: Center(
                      child: HyphenatedText(
                        l10n.noPrayerContentAvailable,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  );
                }
                final selectedGroup = _selectedGroupBlock(data);
                // Everything below the Amen is information only. It is rendered
                // on a full-bleed `mutedSurface` band so the change of zone is
                // unmistakable and the Amen clearly reads as the end of the
                // prayer action rather than another block in the flow.
                final infoBlocks = <Widget>[
                  if (selectedGroup != null)
                    PeopleGroupOfTheDayView(
                      name: selectedGroup.title,
                      data: selectedGroup.peopleGroupData!,
                      heading: l10n.myPeopleGroupTitle,
                    ),
                  if (data.metadata.copyrightNotices.isNotEmpty)
                    _CopyrightNotices(notices: data.metadata.copyrightNotices),
                ];
                // A ListView here collapsed the entire prayer body into a
                // single merged semantics node (TalkBack read the whole page at
                // once, only stopping on headings); a SingleChildScrollView +
                // Column keeps every block as its own accessibility stop. The
                // Column must stretch so the full-bleed colour bands still fill
                // the width the way ListView children did.
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Action zone: an explicit white surface so the prayer
                      // content reads as a distinct zone against both the app's
                      // patterned background and the muted info band below. The
                      // scaffold is transparent over that pattern, so without this
                      // the prayer section and the band have too little contrast.
                      ColoredBox(
                        color: AppColors.surface,
                        child: PageContainer(
                          verticalPadding: AppSpacing.xs,
                          bottomPadding: AppSpacing.xxxl,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const PrayingNowBanner(),
                              PrayerContentView(response: data),
                              const SizedBox(height: AppSpacing.xxl),
                              ActionButton(
                                label: l10n.amen,
                                onPressed: _submitting ? null : _onAmen,
                                color: ActionButtonColor.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (infoBlocks.isNotEmpty)
                        ColoredBox(
                          color: AppColors.mutedSurface,
                          child: PageContainer(
                            verticalPadding: AppSpacing.xxxl,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: AppSpacing.xxl,
                              children: infoBlocks,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Header showing the displayed date flanked by previous/next day arrows.
///
/// The buttons are laid out as a `Row` using semantic previous/next roles, so
/// Flutter mirrors them automatically under RTL (Arabic): the visual left arrow
/// moves forward and the visual right arrow moves backward. Chevron glyphs are
/// chosen from the ambient text direction so the leading arrow always points
/// "back" and the trailing arrow "forward". Disabled arrows are greyed out.
class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime date;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final label = intl.DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    ).format(date);
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.md,
          children: [
            IconButton(
              icon: TriangleIcon(
                direction: isRtl
                    ? TriangleDirection.right
                    : TriangleDirection.left,
                color: canGoPrevious
                    ? AppColors.primary
                    : AppColors.primaryLight,
                size: 12,
              ),
              tooltip: l10n.previousDay,
              onPressed: canGoPrevious ? onPrevious : null,
            ),
            Expanded(
              child: HyphenatedText(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: TriangleIcon(
                direction: isRtl
                    ? TriangleDirection.left
                    : TriangleDirection.right,
                color: canGoNext ? AppColors.primary : AppColors.onPrimary,
                size: 12,
              ),
              tooltip: l10n.nextDay,
              onPressed: canGoNext ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Scripture copyright notices shown at the very bottom of the prayer content,
/// mirroring the web `PrayerFuelDisplay`: a thin left rule with small, italic,
/// muted lines — one per quoted translation.
class _CopyrightNotices extends StatelessWidget {
  const _CopyrightNotices({required this.notices});

  final List<CopyrightNotice> notices;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: AppColors.outline, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xxs,
          children: [
            for (final notice in notices)
              HyphenatedText(
                notice.notice,
                style: AppTypography.caption.copyWith(
                  fontSize: AppTypography.xxs,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primaryLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.lg,
        children: [
          HyphenatedText(message, textAlign: TextAlign.center),
          ActionButton(
            label: AppLocalizations.of(context)!.retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
