import 'package:flutter/material.dart';

class CheckIcon extends StatelessWidget {
  const CheckIcon({
    super.key,
    this.size = 24,
    this.color,
    this.cornerRadius = 0,
  });

  final double size;
  final Color? color;
  final double cornerRadius;

  double get thickness => size / 3;

  @override
  Widget build(BuildContext context) {
    final tint =
        color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CheckPainter(
          color: tint,
          thickness: thickness,
          cornerRadius: cornerRadius,
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.color,
    required this.thickness,
    required this.cornerRadius,
  });

  final Color color;
  final double thickness;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = cornerRadius.clamp(0.0, thickness / 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = radius > 0 ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin = radius > 0 ? StrokeJoin.round : StrokeJoin.miter;

    final start = Offset(size.width * 0.10, size.height * 0.45);
    final corner = Offset(size.width * 0.42, size.height * 0.75);
    final end = Offset(size.width * 0.92, size.height * 0.20);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(corner.dx, corner.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.cornerRadius != cornerRadius;
}
