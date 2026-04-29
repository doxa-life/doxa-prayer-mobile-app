import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:flutter/material.dart';

import '../components/cards/reminder_card.dart';
import '../components/misc/plus_icon.dart';
import '../components/reminders/reminder_editor.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/reminders_controller.dart';
import '../services/reminders_format.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: PageContainer(
        child: ValueListenableBuilder<Reminders?>(
          valueListenable: remindersController,
          builder: (context, reminders, _) {
            final list = reminders?.list ?? const <Reminder>[];
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Text(
                    l.noRemindersYet,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: AppSpacing.xxl,
                  children: [
                    H1(l.reminders),
                    Column(
                      children: [
                        for (final r in list)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: ReminderCard(
                              time: formatReminderTime(context, r),
                              daysSummary: formatReminderDays(context, r),
                              enabled: r.enabled,
                              onToggle: (v) => setReminderEnabled(r.id, v),
                              onTap: () =>
                                  showReminderEditor(context, existing: r),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showReminderEditor(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        tooltip: l.newReminder,
        child: const PlusIcon(color: AppColors.onPrimary, size: 24),
      ),
    );
  }
}
