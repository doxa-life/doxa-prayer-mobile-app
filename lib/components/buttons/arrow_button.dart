import 'package:flutter/material.dart';

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
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: TriangleIcon(
              direction: triangleDirection,
              color: AppColors.onPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
