import 'dart:math';

import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/prayer_content/prayer_content_view.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../models/prayer_content.dart';
import '../services/locale_controller.dart';
import '../services/prayer_content_service.dart';
import '../services/selected_people_group_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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

class _PrayContentState extends State<_PrayContent> {
  late Future<PrayerContentResponse> _future;
  late DateTime _date;
  late DateTime _openedAt;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _openedAt = DateTime.now();
    _future = fetchPrayerContent(
      slug: widget.slug,
      date: _date,
      language: widget.language,
    );
  }

  void _reload() {
    setState(() {
      _openedAt = DateTime.now();
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
    if (_submitting) return;
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final report = PrayerSessionReport(
      sessionId: _generateId(),
      trackingId: _generateId(),
      duration: DateTime.now().difference(_openedAt).inSeconds,
      timestamp: DateTime.now().toUtc().toIso8601String(),
    );
    try {
      await postPrayerSession(
        slug: widget.slug,
        date: _date,
        report: report,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xxl,
                  children: [
                    PrayerContentView(response: data),
                    ActionButton.fullWidth(
                      label: l10n.amen,
                      onPressed: _submitting ? null : _onAmen,
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
