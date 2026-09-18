import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/hyphenated_text.dart';

/// Flies the people-group map back to the group it was opened for.
///
/// Labelled rather than icon-only: it appears only once the focused pin has
/// been panned off screen, so it arrives unannounced and has to say what it
/// does. Without it the map is a one-way trip — pan away and the only route
/// back is leaving the screen and re-entering it.
class MapRecentreButton extends StatelessWidget {
  const MapRecentreButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              const AppIcon(
                AppIconName.geoAlt,
                size: 18,
                color: AppColors.primary,
              ),
              HyphenatedText(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
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
