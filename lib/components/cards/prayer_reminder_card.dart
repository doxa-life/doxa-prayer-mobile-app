import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../services/prayer_reminder_controller.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/hyphenated_text.dart';
import 'elevated_card.dart';

/// Takes the place of the reminders card on the home screen while [group] still
/// needs today's prayer. Both tapping it (which opens the Pray tab on [group])
/// and the "×" dismiss it for the session; once no group is left to nudge
/// about, the "next reminder in…" card comes back.
class PrayerReminderCard extends StatelessWidget {
  const PrayerReminderCard({super.key, required this.group});

  final SubscribedPeopleGroup group;

  /// Praying from the nudge also makes [group] active, so the Pray tab opens on
  /// the group the card named rather than whatever it showed last — matching
  /// how the people group cards behave.
  Future<void> _pray(BuildContext context) async {
    // Held before the await: dismissing the nudge takes this card off the home
    // screen, so by the time the write lands its BuildContext is gone and
    // `context.goNamed` would silently do nothing — leaving the user on the
    // home screen with the carousel moved but no Pray tab. The router outlives
    // the card.
    final router = GoRouter.of(context);

    await setActivePeopleGroup(group.slug);
    // Answering the nudge counts as dealing with it: coming back to the home
    // screen moves on to the next group that needs prayer, or to the usual
    // reminder card — whether or not the user finished praying.
    dismissPrayerReminder(group.slug);
    router.goNamed(AppRoute.pray.name);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ElevatedAppCard(
      color: AppColors.secondary,
      onTap: () => _pray(context),
      padding: AppSpacing.xl,
      // Keep the dismiss "×" as its own semantics node so screen readers can
      // reach it independently of tapping the card to pray.
      mergeSemantics: false,
      child: Row(
        spacing: AppSpacing.md,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppIcon(AppIconName.bell, color: AppColors.onSecondary),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HyphenatedText(
                  l.prayerReminderTitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                HyphenatedText(
                  l.prayerReminderBody(group.name),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.onSecondary),
            tooltip: l.dismissReminderLabel,
            visualDensity: VisualDensity.compact,
            onPressed: () => dismissPrayerReminder(group.slug),
          ),
        ],
      ),
    );
  }
}
