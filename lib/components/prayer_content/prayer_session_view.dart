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
import '../../services/cache_warmup.dart';
import '../../services/crash_reporting_service.dart';
import '../../services/identity_service.dart';
import '../../services/prayer_content_service.dart';
import '../../services/prayer_history_service.dart';
import '../../services/prayer_stats_service.dart';
import '../../services/thank_you_verse_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_icon.dart';
import '../misc/cached_data_builder.dart';
import 'people_group_of_the_day_view.dart';
import 'praying_now_banner.dart';
import 'prayer_content_skeleton.dart';
import '../nav/sheet_page.dart';
import 'prayer_calendar_sheet.dart';
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
    this.inPrayTab = false,
    this.header,
  });

  final String slug;
  final String language;
  final bool Function() isActive;
  final DateTime? initialDate;

  /// Whether this is the Pray tab's view rather than a standalone prayer
  /// screen. The calendar sheet it opens says so in its location, so the tab
  /// knows the user is still on it — choosing a day — and keeps its session
  /// and any deep-link override.
  final bool inPrayTab;

  /// Shown above the prayer, inside its scroll, and kept as it is when the
  /// prayer under it changes — the Pray tab's group cards. A change of [slug]
  /// then only fades the prayer itself: the view is not rebuilt for it.
  final Widget? header;

  @override
  State<PrayerSessionView> createState() => _PrayerSessionViewState();
}

class _PrayerSessionViewState extends State<PrayerSessionView>
    with WidgetsBindingObserver {
  late DateTime _date;

  /// The scroll the header and the prayer share; back to the top for a new
  /// day.
  final ScrollController _scroll = ScrollController();

  /// Which way the last change of day went: +1 later, -1 earlier. The date's
  /// words slide that way; nothing else in the bar moves.
  int _dayDirection = 0;
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
    _prefetchNeighbouringDays();
  }

  /// Once the day on show has loaded, the days either side of it — where the
  /// arrows go next — so stepping to one is a slide, not a skeleton. After the
  /// day on show, not alongside it, so they never slow it down.
  void _prefetchNeighbouringDays() {
    final date = _date;
    _load().then((_) {
      if (!mounted || date != _date) return;
      if (_canGoPrevious) {
        prefetchPrayer(
          slug: widget.slug,
          date: date.subtract(const Duration(days: 1)),
          language: widget.language,
        );
      }
      if (_canGoNext) {
        prefetchPrayer(
          slug: widget.slug,
          date: date.add(const Duration(days: 1)),
          language: widget.language,
        );
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    if (_sessionActive) {
      _endSession();
    }
    _cancelSessionPings();
    _scroll.dispose();
    super.dispose();
  }

  /// The Pray tab keeps this view and hands it a new [PrayerSessionView.slug]
  /// when the user switches group, rather than building another — so the
  /// cards above the prayer stay exactly as they were mid-swipe, and only the
  /// prayer fades. The old group's session ends here as it would have on
  /// dispose, and the new group's starts; the day on show stays.
  @override
  void didUpdateWidget(PrayerSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final date = widget.initialDate;
    if (date != null && date != oldWidget.initialDate) {
      _date = date;
    }
    if (widget.slug == oldWidget.slug) return;
    if (_sessionActive) _endSession(slug: oldWidget.slug);
    _cancelSessionPings();
    if (widget.isActive()) _startSession();
    _prefetchNeighbouringDays();
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

  /// [slug] is the group the session was for — the old one, when the view
  /// has just been handed a new group.
  void _endSession({String? slug}) {
    _sessionActive = false;
    _cancelSessionPings();
    if (!_amenFired) {
      _amenFired = true;
      _recordAmenInBackground(slug ?? widget.slug);
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

  void _recordAmenInBackground(String slug) {
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
    // Back to the top for the new day, gliding rather than jumping.
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
    _prefetchNeighbouringDays();
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
    _dayDirection = -1;
    _date = _date.subtract(const Duration(days: 1));
    _showCurrentDate();
  }

  void _goToNextDay() {
    if (!_canGoNext) return;
    _dayDirection = 1;
    _date = _date.add(const Duration(days: 1));
    _showCurrentDate();
  }

  /// How far back the calendar reaches when the campaign's start isn't known
  /// yet (no day has loaded): far enough for any real campaign, and the
  /// server answers a day before its start with "no content".
  static const Duration _calendarFallbackReach = Duration(days: 365 * 2);

  /// Picks the day from a calendar, in a sheet over the prayer, rather than
  /// stepping one day at a time.
  Future<void> _openCalendar() async {
    final today = _dateOnly(DateTime.now());
    final picked = await pushSheet<DateTime>(
      context,
      widget.inPrayTab ? '/calendar?from=pray' : '/calendar',
      extra: PrayerCalendarArgs(
        selected: _date,
        firstDay: _campaignStartDate ?? today.subtract(_calendarFallbackReach),
        lastDay: today,
      ),
    );
    if (!mounted || picked == null) return;
    if (_dateOnly(picked) == _dateOnly(_date)) return;
    _dayDirection = _dateOnly(picked).isAfter(_dateOnly(_date)) ? 1 : -1;
    _date = picked;
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
    final cacheKey = prayerContentCacheKey(
      slug: widget.slug,
      date: _date,
      language: widget.language,
    );
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _DateNavigator(
            date: _date,
            direction: _dayDirection,
            canGoPrevious: _canGoPrevious,
            canGoNext: _canGoNext,
            onPrevious: _goToPreviousDay,
            onNext: _goToNextDay,
            onPickDate: _openCalendar,
          ),
          Expanded(
            // A SingleChildScrollView + Column rather than a ListView: a
            // ListView collapsed the whole prayer into one merged semantics
            // node (TalkBack read the page at once, stopping only on
            // headings); this keeps every block its own accessibility stop.
            // The Column stretches so the full-bleed colour bands fill the
            // width.
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.header case final header?)
                    ColoredBox(color: AppColors.surface, child: header),
                  // One builder for every group and day: a change swaps the
                  // prayer in place — the old one stays up until the new one
                  // is here, then only the blocks that differ fade over —
                  // under a header and date bar that never rebuild for it.
                  // Only the very first load shows the skeleton.
                  CachedDataBuilder<PrayerContentResponse>(
                    cacheKey: cacheKey,
                    keepPreviousWhileLoading: true,
                    fadeDuration: const Duration(milliseconds: 220),
                    fetch: _load,
                    loading: (context) => const PrayerContentSkeleton(),
                    error: (context, retry) => PageContainer(
                      child: _ErrorView(
                        message: l10n.couldNotLoadPrayerContent,
                        onRetry: retry,
                      ),
                    ),
                    builder: (context, data) => _prayer(l10n, data),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One day's prayer: the action zone, then the information band.
  Widget _prayer(AppLocalizations l10n, PrayerContentResponse data) {
    _captureStartDate(data.globalStartDate);
    if (!data.hasContent || data.content.isEmpty) {
      return PageContainer(
        child: HyphenatedText(
          l10n.noPrayerContentAvailable,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium,
        ),
      );
    }
    // Everything below the Amen is information only. It is rendered on a
    // full-bleed `mutedSurface` band so the change of zone is unmistakable and
    // the Amen clearly reads as the end of the prayer action rather than
    // another block in the flow.
    final notices = data.metadata.copyrightNotices;
    final ofTheDay = data.content
        .where(
          (b) =>
              b.type == PrayerContentBlockType.peopleGroupOfTheDay &&
              b.peopleGroupData != null,
        )
        .firstOrNull;
    final infoBlocks = <Widget>[
      // The People Group of the Day closes the page, after the Amen: something
      // to read about once the prayer is done, not part of it.
      if (ofTheDay != null)
        BlockSwap(
          child: PeopleGroupOfTheDayView(
            // Changes only when the group of the day does.
            key: ValueKey('of-the-day-${ofTheDay.title}'),
            name: ofTheDay.title,
            data: ofTheDay.peopleGroupData!,
            heading: l10n.peopleGroupOfTheDay,
          ),
        ),
      if (notices.isNotEmpty)
        BlockSwap(
          child: _CopyrightNotices(
            // Changes only when the translations quoted do.
            key: ValueKey(notices.map((n) => n.id).join(',')),
            notices: notices,
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Action zone: an explicit white surface so the prayer content reads
        // as a distinct zone against both the app's patterned background and
        // the muted info band below. The scaffold is transparent over that
        // pattern, so without this the prayer section and the band have too
        // little contrast.
        ColoredBox(
          color: AppColors.surface,
          child: PageContainer(
            verticalPadding: AppSpacing.xs,
            bottomPadding: AppSpacing.xxxl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PrayingNowBanner(),
                PrayerContentView(
                  response: data,
                  // Under the group cards, the card says who this is for.
                  showIntro: widget.header == null,
                ),
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
class _DateNavigator extends StatefulWidget {
  const _DateNavigator({
    required this.date,
    required this.direction,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  final DateTime date;

  /// Which way the last change of day went (+1 later, -1 earlier), for the
  /// way the date's words slide.
  final int direction;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Opens the calendar, from a tap on the date itself.
  final VoidCallback onPickDate;

  @override
  State<_DateNavigator> createState() => _DateNavigatorState();
}

/// The bar stays as it is for a change of day — only the date's words slide
/// over — and never changes for a change of group.
///
/// A sideways swipe on the bar steps a day, as the arrows do: toward the
/// start of the row for the day before, as reading order runs. The swipe is
/// the bar's alone: it starts on the bar, so the tabs underneath don't move.
class _DateNavigatorState extends State<_DateNavigator> {
  /// How far the current swipe has travelled.
  double _drag = 0;

  /// A swipe this long, or this fast, changes day.
  static const double _swipeDistance = 40;
  static const double _swipeVelocity = 300;

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final distance = _drag;
    _drag = 0;
    final moved = distance.abs() >= _swipeDistance
        ? distance
        : velocity.abs() >= _swipeVelocity
        ? velocity
        : 0.0;
    if (moved == 0) return;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // Dragged toward the end of the row (right, in a left-to-right
    // language): the day before comes in from the start.
    final towardEnd = (moved > 0) != rtl;
    if (towardEnd) {
      if (widget.canGoPrevious) widget.onPrevious();
    } else {
      if (widget.canGoNext) widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final label = intl.DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    ).format(widget.date);
    final slide = 0.25 * widget.direction.sign * (isRtl ? -1 : 1);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _drag = 0,
      onHorizontalDragUpdate: (d) => _drag += d.primaryDelta ?? 0,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: () => _drag = 0,
      child: ColoredBox(
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
                  color: widget.canGoPrevious
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  size: 12,
                ),
                tooltip: l10n.previousDay,
                onPressed: widget.canGoPrevious ? widget.onPrevious : null,
              ),
              Expanded(
                child: Tooltip(
                  message: l10n.chooseDay,
                  child: Semantics(
                    button: true,
                    hint: l10n.chooseDay,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: widget.onPickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: AppSpacing.sm,
                          children: [
                            const AppIcon(
                              AppIconName.calendar,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            Flexible(
                              child: ClipRect(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  reverseDuration: const Duration(
                                    milliseconds: 120,
                                  ),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, animation) {
                                    final incoming =
                                        child.key == ValueKey(label);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: Offset(
                                            incoming ? slide : -slide,
                                            0,
                                          ),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: HyphenatedText(
                                    label,
                                    key: ValueKey(label),
                                    textAlign: TextAlign.center,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: TriangleIcon(
                  direction: isRtl
                      ? TriangleDirection.left
                      : TriangleDirection.right,
                  color: widget.canGoNext
                      ? AppColors.primary
                      : AppColors.onPrimary,
                  size: 12,
                ),
                tooltip: l10n.nextDay,
                onPressed: widget.canGoNext ? widget.onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scripture copyright notices shown at the very bottom of the prayer content,
/// mirroring the web `PrayerFuelDisplay`: a thin left rule with small, italic,
/// muted lines — one per quoted translation.
class _CopyrightNotices extends StatelessWidget {
  const _CopyrightNotices({super.key, required this.notices});

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
