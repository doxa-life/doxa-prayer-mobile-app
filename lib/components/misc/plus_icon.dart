import 'package:flutter/material.dart';

class PlusIcon extends StatelessWidget {
  const PlusIcon({
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
    final tint =
        color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlusPainter(
          color: tint,
          thickness: thickness,
          cornerRadius: cornerRadius,
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter({
    required this.color,
    required this.thickness,
    required this.cornerRadius,
  });

  final Color color;
  final double thickness;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final halfThickness = thickness / 2;
    final maxRadius = halfThickness;
    final radius = cornerRadius.clamp(0.0, maxRadius);

    final horizontal = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        0,
        center.dy - halfThickness,
        size.width,
        center.dy + halfThickness,
      ),
      Radius.circular(radius),
    );

    final vertical = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        center.dx - halfThickness,
        0,
        center.dx + halfThickness,
        size.height,
      ),
      Radius.circular(radius),
    );

    canvas.drawRRect(horizontal, paint);
    canvas.drawRRect(vertical, paint);
  }

  @override
  bool shouldRepaint(covariant _PlusPainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.cornerRadius != cornerRadius;
}
