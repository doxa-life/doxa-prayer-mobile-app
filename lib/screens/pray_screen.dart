import 'dart:math';
import 'dart:developer' as developer;

import 'package:doxa_prayer_mobile_app/components/misc/triangle_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../components/buttons/action_button.dart';
import '../components/prayer_content/people_group_of_the_day_view.dart';
import '../components/prayer_content/prayer_content_view.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../models/prayer_content.dart';
import '../services/identity_service.dart';
import '../services/locale_controller.dart';
import '../services/prayer_content_service.dart';
import '../services/prayer_history_service.dart';
import '../router.dart';
import '../services/selected_people_group_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

const _minimumDurationInSeconds = 5;

class PrayScreen extends StatelessWidget {
  const PrayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SelectedPeopleGroup?>(
      valueListenable: selectedPeopleGroupController,
      builder: (context, selected, _) {
        if (selected == null) {
          return const PageContainer(child: _NoSelectionView());
        }
        return ValueListenableBuilder<Locale>(
          valueListenable: localeController,
          builder: (context, locale, _) {
            return _PrayContent(
              key: ValueKey('${selected.slug}-${locale.languageCode}'),
              slug: selected.slug,
              language: locale.languageCode,
            );
          },
        );
      },
    );
  }
}

class _NoSelectionView extends StatelessWidget {
  const _NoSelectionView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.noPeopleGroupSelected,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium,
      ),
    );
  }
}

class _PrayContent extends StatefulWidget {
  const _PrayContent({super.key, required this.slug, required this.language});

  final String slug;
  final String language;

  @override
  State<_PrayContent> createState() => _PrayContentState();
}

class _PrayContentState extends State<_PrayContent>
    with WidgetsBindingObserver {
  late Future<PrayerContentResponse> _future;
  late DateTime _date;
  DateTime? _campaignStartDate;
  DateTime? _openedAt;
  bool _submitting = false;
  bool _amenFired = false;
  bool _sessionActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appRouter.routerDelegate.addListener(_onRouteChanged);
    _date = DateTime.now();
    _future = fetchPrayerContent(
      slug: widget.slug,
      date: _date,
      language: widget.language,
    );
    if (_isOnPrayRoute) {
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
      if (_isOnPrayRoute && !_sessionActive) {
        _startSession();
      }
    }
  }

  bool get _isOnPrayRoute =>
      appRouter.routerDelegate.currentConfiguration.uri.path == '/pray';

  void _onRouteChanged() {
    final isPray = _isOnPrayRoute;
    if (isPray && !_sessionActive) {
      _startSession();
    } else if (!isPray && _sessionActive) {
      _endSession();
    }
  }

  void _startSession() {
    _openedAt = DateTime.now();
    _amenFired = false;
    _sessionActive = true;
    developer.log('Session started at: $_openedAt', name: 'pray_screen');
  }

  void _endSession() {
    _sessionActive = false;
    if (!_amenFired) {
      _amenFired = true;
      _recordAmenInBackground();
    }
  }

  void _recordAmenInBackground() {
    final openedAt = _openedAt;
    if (openedAt == null) return;
    final now = DateTime.now();
    final duration = now.difference(openedAt).inSeconds;
    if (duration <= _minimumDurationInSeconds) return;
    final timestamp = now.toUtc().toLocal().toIso8601String();
    final report = PrayerSessionReport(
      sessionId: _generateId(),
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
            openedAtTimestamp: openedAt.toUtc().toLocal().toIso8601String(),
          ),
        );
      } catch (_) {}
    });
  }

  void _reload() {
    setState(() {
      if (_sessionActive) {
        _openedAt = DateTime.now();
      }
      _future = fetchPrayerContent(
        slug: widget.slug,
        date: _date,
        language: widget.language,
      );
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
    _reload();
  }

  void _goToNextDay() {
    if (!_canGoNext) return;
    _date = _date.add(const Duration(days: 1));
    _reload();
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

  /// The intro `people_group` block — the user's selected group, whose full
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
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final duration = now.difference(openedAt).inSeconds;
    final timestamp = now.toUtc().toLocal().toIso8601String();
    final report = PrayerSessionReport(
      sessionId: _generateId(),
      trackingId: identityController.value?.trackingId ?? '',
      duration: duration,
      timestamp: timestamp,
    );
    try {
      await postPrayerSession(slug: widget.slug, date: _date, report: report);
      await recordPrayer(
        PrayerRecord(
          slug: widget.slug,
          durationSeconds: duration,
          timestamp: timestamp,
          openedAtTimestamp: openedAt.toUtc().toLocal().toIso8601String(),
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.prayerLogged)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotLogPrayerSession)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        children: [
          _DateNavigator(
            date: _date,
            canGoPrevious: _canGoPrevious,
            canGoNext: _canGoNext,
            onPrevious: _goToPreviousDay,
            onNext: _goToNextDay,
          ),
          Expanded(
            child: FutureBuilder<PrayerContentResponse>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return PageContainer(
                    child: _ErrorView(
                      message: l10n.couldNotLoadPrayerContent,
                      onRetry: _reload,
                    ),
                  );
                }
                final data = snapshot.data!;
                _captureStartDate(data.globalStartDate);
                if (!data.hasContent || data.content.isEmpty) {
                  return PageContainer(
                    child: Center(
                      child: Text(
                        l10n.noPrayerContentAvailable,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  );
                }
                final selectedGroup = _selectedGroupBlock(data);
                return ListView(
                  children: [
                    PageContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppSpacing.xxl,
                        children: [
                          PrayerContentView(response: data),
                          ActionButton(
                            label: l10n.amen,
                            onPressed: _submitting ? null : _onAmen,
                            color: ActionButtonColor.secondary,
                          ),
                          if (selectedGroup != null)
                            PeopleGroupOfTheDayView(
                              name: selectedGroup.title,
                              data: selectedGroup.peopleGroupData!,
                              heading: l10n.myPeopleGroupTitle,
                            ),
                        ],
                      ),
                    ),
                  ],
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
    return Padding(
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
              color: canGoPrevious ? AppColors.primary : AppColors.primaryLight,
              size: 12,
            ),
            tooltip: l10n.previousDay,
            onPressed: canGoPrevious ? onPrevious : null,
          ),
          Expanded(
            child: Text(
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
          Text(message, textAlign: TextAlign.center),
          ActionButton(
            label: AppLocalizations.of(context)!.retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
