import 'package:doxa_prayer_mobile_app/components/misc/plus_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    this.leadingIcon,
    required this.onPressed,
  });

  final String label;
  final Widget? leadingIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                leadingIcon ?? const SizedBox.shrink(),
                Text(
                  label.toUpperCase(),
                  style: AppTypography.h2.copyWith(color: AppColors.white),
                ),
              ],
            ),
            Container(
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: AppColors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: Center(
                child: PlusIcon(
                  color: AppColors.primary,
                  size: 20,
                  thickness: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
