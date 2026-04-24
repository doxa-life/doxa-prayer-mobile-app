import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          _Dot(active: i == currentIndex),
          if (i < count - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;
  static const double size = 16;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
      width: active ? size * 2 : size,
      height: size,
      decoration: BoxDecoration(
        color: active ? AppColors.secondary : AppColors.outline,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
