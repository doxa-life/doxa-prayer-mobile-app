import 'dart:math' as math;

import 'package:flutter/material.dart';

enum TriangleDirection { left, right, up, down }

class TriangleIcon extends StatelessWidget {
  const TriangleIcon({
    super.key,
    this.direction = TriangleDirection.left,
    this.size = 8,
    this.color,
    this.cornerRadius = 2,
  });

  final TriangleDirection direction;
  final double size;
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
        painter: _TrianglePainter(
          color: tint,
          cornerRadius: cornerRadius,
          direction: direction,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    required this.color,
    required this.cornerRadius,
    required this.direction,
  });

  final Color color;
  final double cornerRadius;
  final TriangleDirection direction;

  static const _angles = <TriangleDirection, double>{
    TriangleDirection.left: 0,
    TriangleDirection.down: math.pi / 2,
    TriangleDirection.right: math.pi,
    TriangleDirection.up: 3 * math.pi / 2,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final base = side;
    final width = base * math.sqrt(3) / 2;
    final xOffset = (size.width - width) / 2;
    final yOffset = (size.height - base) / 2;

    final tip = Offset(xOffset, yOffset + base / 2);
    final topRight = Offset(xOffset + width, yOffset);
    final bottomRight = Offset(xOffset + width, yOffset + base);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_angles[direction]!);
    canvas.translate(-center.dx, -center.dy);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    final round = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = cornerRadius * 2;
    canvas.drawPath(path, round);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) =>
      old.color != color ||
      old.cornerRadius != cornerRadius ||
      old.direction != direction;
}
