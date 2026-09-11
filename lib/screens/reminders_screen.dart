import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:doxa_prayer_mobile_app/layouts/fill_viewport_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/action_button.dart';
import '../components/cards/reminder_card.dart';
import '../components/misc/hyphenated_text.dart';
import '../components/misc/plus_icon.dart';
import '../components/reminders/exact_alarm_warning_banner.dart';
import '../components/reminders/reminder_editor.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/reminders_controller.dart';
import '../services/reminders_format.dart';
import '../services/reminders_notifications.dart';
import '../services/subscribed_people_groups_controller.dart';
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
      // No people groups means no reminder can be created — every reminder
      // belongs to one. The empty state offers the way out instead.
      floatingActionButton: ValueListenableBuilder<SubscribedPeopleGroups>(
        valueListenable: peopleGroupsController,
        builder: (context, groups, _) {
          if (groups.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => showReminderEditor(context),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: const CircleBorder(),
            tooltip: l.newReminder,
            child: const PlusIcon(color: AppColors.onPrimary, size: 24),
          );
        },
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
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, groups, _) => ValueListenableBuilder<Reminders?>(
        valueListenable: remindersController,
        builder: (context, reminders, _) =>
            _buildList(context, l, groups, reminders),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l,
    SubscribedPeopleGroups groups,
    Reminders? reminders,
  ) {
    // Sorted by time: the screen answers "when do I get reminded?", and the
    // group name on each card carries the grouping.
    final list = [...(reminders?.list ?? const <Reminder>[])]
      ..sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    if (list.isEmpty) {
      // Fills the viewport (message centered in the remaining space)
      // and scrolls when the banner alone is taller than the screen.
      return FillViewportScrollView(
        padKeyboardInset: false,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Equal slack above and below the message centres it in the
          // space left under the banner, without a flex child.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Column(
                children: [
                  HyphenatedText(
                    groups.isEmpty
                        ? l.noPeopleGroupsForReminder
                        : l.noRemindersYet,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (groups.isEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    ActionButton(
                      label: l.choosePeopleGroup,
                      color: ActionButtonColor.secondary,
                      onPressed: () => context.go('/people-groups'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox.shrink(),
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
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ReminderCard(
                      peopleGroupName: groups.bySlug(r.slug)?.name,
                      time: formatReminderTime(context, r),
                      daysSummary: formatReminderDays(context, r),
                      enabled: r.enabled,
                      onToggle: (v) => setReminderEnabled(r.id, v),
                      onTap: () => showReminderEditor(context, existing: r),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
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
                  child: HyphenatedText(
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
