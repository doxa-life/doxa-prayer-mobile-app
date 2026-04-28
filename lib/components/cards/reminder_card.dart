import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import 'flat_card.dart';

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
    return FlatCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
