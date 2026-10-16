import 'package:doxa_prayer_mobile_app/components/misc/plus_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../misc/hyphenated_text.dart';

const double _leadingIconSize = 24;

class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    required this.onPressed,
  });

  final String label;
  final Widget? leadingIcon;

  /// Drawn in the white circle at the end, in the button's colour. Defaults to
  /// a plus, for buttons that set something up.
  final Widget? trailingIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 6,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // A fixed slot, so whatever icon a button has, its label
                  // starts at the same place as every other button's.
                  if (leadingIcon != null) ...[
                    SizedBox.square(
                      dimension: _leadingIconSize,
                      child: IconTheme.merge(
                        data: const IconThemeData(
                          size: _leadingIconSize,
                          color: AppColors.white,
                        ),
                        child: Center(child: leadingIcon!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: HyphenatedText(
                      label.toUpperCase(),
                      style: AppTypography.h2.copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: AppColors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: Center(
                child:
                    trailingIcon ??
                    PlusIcon(color: AppColors.primary, size: 20, thickness: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
