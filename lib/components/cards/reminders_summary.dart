import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_format.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import 'elevated_card.dart';
import '../misc/hyphenated_text.dart';

class RemindersSummary extends StatelessWidget {
  const RemindersSummary({super.key, required this.reminders});

  final Reminders reminders;

  /// The next firing, named with its people group when the user prays for more
  /// than one — otherwise the group adds nothing they don't already know.
  String _nextLabel(BuildContext context, NextReminder next) {
    final l = AppLocalizations.of(context)!;
    final when = formatNextReminderWhen(context, next.firesAt);
    final groups = peopleGroupsController.value;
    if (groups.list.length < 2) return when;
    final name = groups.bySlug(next.reminder.slug)?.name;
    return name == null ? when : l.nextReminderForGroup(when, name);
  }

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
                      HyphenatedText(
                        l.nextReminder,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      HyphenatedText(
                        _nextLabel(context, next),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ] else
                      HyphenatedText(
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
