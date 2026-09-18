import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'hyphenated_text.dart';

/// A small rounded badge stating a fact about a people group — "Prayed today",
/// "Selected". A status indicator, never a control.
///
/// The shape lives here so the badges stay identical wherever they appear and
/// only their colour and wording differ; see [PrayedTodayPill] and
/// [SelectedPill], which are the two the app uses.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final Color color;
  final IconData icon;

  /// Drops the text, leaving just the icon — for places where a full pill
  /// would be wider than what it sits on, such as the Pray tab's avatars.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Merge the decorative icon and the label into a single node so screen
    // readers announce just "<label>".
    return MergeSemantics(
      child: Semantics(
        label: compact ? label : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.xxs : AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              Icon(icon, size: 16, color: AppColors.onSecondary),
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
