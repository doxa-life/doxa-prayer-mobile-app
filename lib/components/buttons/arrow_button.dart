import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../misc/triangle_icon.dart';

enum ArrowDirection { back, forward }

class ArrowButton extends StatelessWidget {
  const ArrowButton({
    super.key,
    required this.direction,
    required this.onPressed,
  });

  final ArrowDirection direction;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final triangleDirection = direction == ArrowDirection.back
        ? TriangleDirection.left
        : TriangleDirection.right;
    final label = direction == ArrowDirection.back
        ? MaterialLocalizations.of(context).backButtonTooltip
        : AppLocalizations.of(context)!.forwardLabel;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: TriangleIcon(
                direction: triangleDirection,
                color: AppColors.primary,
                size: AppTypography.sm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
