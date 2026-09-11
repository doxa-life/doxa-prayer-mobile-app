import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'hyphenated_text.dart';

/// "Prayed today" badge. Shared by the home carousel's cards and the Pray
/// tab's people group row, so today's progress reads the same in both places.
class PrayedTodayPill extends StatelessWidget {
  const PrayedTodayPill({super.key, required this.label, this.compact = false});

  final String label;

  /// Drops the text, leaving just the check — for the Pray tab's avatars,
  /// where a full pill would be wider than the avatar it sits on.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // A status indicator, not a control: merge the decorative check icon and
    // label into a single node so screen readers announce just "<label>".
    return MergeSemantics(
      child: Semantics(
        label: compact ? label : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.xxs : AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              const Icon(Icons.check, size: 16, color: AppColors.onSecondary),
              if (!compact)
                HyphenatedText(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
