import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'plus_icon.dart';

class CloseIcon extends StatelessWidget {
  const CloseIcon({
    super.key,
    this.size = 24,
    this.thickness = 5,
    this.color,
    this.cornerRadius = 0,
  });

  final double size;
  final double thickness;
  final Color? color;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: PlusIcon(
        size: size,
        thickness: thickness,
        color: color,
        cornerRadius: cornerRadius,
      ),
    );
  }
}
