import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../services/prayer_history_service.dart';
import '../../services/prayer_reminder_controller.dart';
import '../../services/selected_people_group_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Overlays [child] with a gentle, dismissable banner pinned to the bottom of
/// the home screen, reminding the user they haven't prayed yet today. Tapping
/// the banner opens the Pray tab; the "×" hides it for the session.
///
/// Self-hiding: renders just [child] unless a people group is selected, the
/// user hasn't prayed for anything today, and the banner hasn't been dismissed
/// this session — so it can be dropped in unconditionally.
class PrayerReminderBanner extends StatelessWidget {
  const PrayerReminderBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        selectedPeopleGroupController,
        prayedTodayController,
        prayerReminderDismissedController,
      ]),
      builder: (context, _) {
        final selected = selectedPeopleGroupController.value;
        final show =
            selected != null &&
            prayedTodayController.value.isEmpty &&
            !prayerReminderDismissedController.value;

        if (!show) return child;

        return Stack(
          children: [
            child,
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _Banner(peopleGroupName: selected.name),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.peopleGroupName});

  final String peopleGroupName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);

    return Material(
      elevation: 4,
      borderRadius: borderRadius,
      color: AppColors.secondary.withValues(alpha: 0.92),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => context.goNamed(AppRoute.pray.name),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.prayerReminderTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.prayerReminderBody(peopleGroupName),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                tooltip: l10n.dismissReminderLabel,
                onPressed: dismissPrayerReminder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
