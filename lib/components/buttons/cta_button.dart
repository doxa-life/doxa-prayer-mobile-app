import 'package:doxa_prayer_mobile_app/components/misc/plus_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../misc/hyphenated_text.dart';

const double _leadingIconSize = 24;

/// The white circle at the end: a 20 icon with 4 all round.
const double _trailingCircleSize = 28;

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
            // As wide as the circle at the other end, with or without an icon
            // in it, so the label between them sits in the button's centre.
            SizedBox.square(
              dimension: _trailingCircleSize,
              child: leadingIcon == null
                  ? null
                  : IconTheme.merge(
                      data: const IconThemeData(
                        size: _leadingIconSize,
                        color: AppColors.white,
                      ),
                      child: Center(child: leadingIcon!),
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: HyphenatedText(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(color: AppColors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: _trailingCircleSize,
              height: _trailingCircleSize,
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: AppColors.white,
              ),
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
