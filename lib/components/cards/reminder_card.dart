import 'package:doxa_prayer_mobile_app/components/cards/elevated_card.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.time,
    required this.daysSummary,
    required this.enabled,
    this.onToggle,
    this.onTap,
  });

  final String time;
  final String daysSummary;
  final bool enabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedAppCard(
      onTap: onTap,
      padding: AppSpacing.xl,
      // Keep the trailing Switch as its own semantics node so screen readers
      // can toggle it independently of tapping the card to edit.
      mergeSemantics: false,
      child: Row(
        children: [
          const AppIcon(AppIconName.bell, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(daysSummary, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}
