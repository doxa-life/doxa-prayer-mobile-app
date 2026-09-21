import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../services/prayer_reminder_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/hyphenated_text.dart';
import 'elevated_card.dart';

/// Takes the place of the reminders card on the home screen while the user
/// hasn't prayed yet today, nudging them to pray for their active people
/// group. Both tapping it (which opens the Pray tab) and the "×" dismiss it for
/// the session, putting the "next reminder in…" card back.
class PrayerReminderCard extends StatelessWidget {
  const PrayerReminderCard({super.key, required this.peopleGroupName});

  final String peopleGroupName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ElevatedAppCard(
      color: AppColors.secondary,
      // Taking the user to the Pray tab counts as answering the nudge: coming
      // back to the home screen shows the usual reminder card, not this one
      // again — whether or not they finished praying.
      onTap: () {
        dismissPrayerReminder();
        context.goNamed(AppRoute.pray.name);
      },
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
                  l.prayerReminderBody(peopleGroupName),
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
            onPressed: dismissPrayerReminder,
          ),
        ],
      ),
    );
  }
}
