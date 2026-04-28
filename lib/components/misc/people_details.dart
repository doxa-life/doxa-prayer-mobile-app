import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class PeopleDetailsView extends StatelessWidget {
  const PeopleDetailsView({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          icon,
          size: AppTypography.caption.fontSize,
          color: AppColors.onSurface.withValues(alpha: 0.5),
        ),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
