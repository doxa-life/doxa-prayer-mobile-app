import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:doxa_prayer_mobile_app/layouts/fill_viewport_scroll_view.dart';
import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/cards/reminder_card.dart';
import '../components/misc/plus_icon.dart';
import '../components/reminders/exact_alarm_warning_banner.dart';
import '../components/reminders/reminder_editor.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/reminders_controller.dart';
import '../services/reminders_format.dart';
import '../services/reminders_notifications.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageContainer(child: _buildReminders(context, l)),
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

  /// The warning banner scrolls with the content (rather than sitting in a
  /// fixed slot above it) so that at large font scales it cannot swallow the
  /// whole viewport. When notifications are off nothing fires at all, so show
  /// that banner alone; otherwise surface the exact-alarm warning (which
  /// self-hides when exact alarms are permitted).
  Widget _buildBanner() {
    return ValueListenableBuilder<bool>(
      valueListenable: notificationsBlocked,
      builder: (context, blocked, _) => blocked
          ? const _NotificationsBlockedBanner()
          : const ExactAlarmWarningBanner(),
    );
  }

  Widget _buildReminders(BuildContext context, AppLocalizations l) {
    return ValueListenableBuilder<Reminders?>(
          valueListenable: remindersController,
          builder: (context, reminders, _) {
            final list = reminders?.list ?? const <Reminder>[];
            if (list.isEmpty) {
              // Fills the viewport (message centered in the remaining space)
              // and scrolls when the banner alone is taller than the screen.
              return FillViewportScrollView(
                padKeyboardInset: false,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBanner(),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl,
                          ),
                          child: Text(
                            l.noRemindersYet,
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              // Bottom padding keeps the last reminder clear of the FAB.
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _buildBanner(),
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
        );
  }
}

class _NotificationsBlockedBanner extends StatelessWidget {
  const _NotificationsBlockedBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_off, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.notificationsDisabledStatus,
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ActionButton.fullWidth(
              label: l.enableNotifications,
              color: ActionButtonColor.secondary,
              onPressed: promptEnableNotifications,
            ),
          ],
        ),
      ),
    );
  }
}
