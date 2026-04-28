import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/prayer_content/prayer_content_view.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../models/prayer_content.dart';
import '../services/locale_controller.dart';
import '../services/prayer_content_service.dart';
import '../services/prayer_history_service.dart';
import '../services/selected_people_group_controller.dart';
import '../services/selected_tab_controller.dart';
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
  DateTime? _openedAt;
  bool _submitting = false;
  bool _amenFired = false;
  bool _sessionActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedTabController.addListener(_onTabChanged);
    _date = DateTime.now();
    _future = fetchPrayerContent(
      slug: widget.slug,
      date: _date,
      language: widget.language,
    );
    if (selectedTabController.value == prayTabIndex) {
      _startSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    selectedTabController.removeListener(_onTabChanged);
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
      if (selectedTabController.value == prayTabIndex && !_sessionActive) {
        _startSession();
      }
    }
  }

  void _onTabChanged() {
    final isPray = selectedTabController.value == prayTabIndex;
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
      trackingId: _generateId(),
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

  String _generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    final rand = Random().nextInt(0x7fffffff).toRadixString(16);
    return '$ms-$rand';
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
      trackingId: _generateId(),
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
    return FutureBuilder<PrayerContentResponse>(
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
        return SafeArea(
          child: ListView(
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
