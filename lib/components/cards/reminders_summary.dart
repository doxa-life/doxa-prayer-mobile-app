import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_format.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import 'elevated_card.dart';

class RemindersSummary extends StatelessWidget {
  const RemindersSummary({super.key, required this.reminders});

  final Reminders reminders;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final next = findNextReminder(reminders.list);
    final total = reminders.list.length;
    final countLabel = l.nRemindersSet(total);

    return ElevatedAppCard(
      color: AppColors.primary,
      onTap: () => context.go('/reminders'),
      padding: AppSpacing.xl,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppIcon(AppIconName.bell, color: AppColors.onPrimary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (next != null) ...[
                      Text(
                        l.nextReminder,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatNextReminderWhen(context, next.firesAt),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ] else
                      Text(
                        countLabel,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
