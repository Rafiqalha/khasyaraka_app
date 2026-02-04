import 'dart:math' as math;

import 'package:flutter/material.dart';

class TopographicBackgroundPainter extends CustomPainter {
  TopographicBackgroundPainter({int seed = 42}) : _random = math.Random(seed);

  final math.Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFFFDFBF7)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    _drawContourLines(canvas, size);
    _drawTerrainDetails(canvas, size);
  }

  void _drawContourLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFDDD6CF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 24; y < size.height; y += 32) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 80) {
        final offset = math.sin((x / size.width) * math.pi * 2 + y / 40) * 6;
        path.quadraticBezierTo(
          x + 40,
          y + offset,
          (x + 80).clamp(0, size.width),
          y,
        );
      }
      canvas.drawPath(path, linePaint);
    }
  }

  void _drawTerrainDetails(Canvas canvas, Size size) {
    final treePaint = Paint()..color = const Color(0xFFB0A79E);
    final rockPaint = Paint()..color = const Color(0xFFC8BFB6);

    for (int i = 0; i < 24; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;
      if (i.isEven) {
        _drawPine(canvas, Offset(dx, dy), treePaint);
      } else {
        canvas.drawCircle(Offset(dx, dy), 2.5, rockPaint);
      }
    }
  }

  void _drawPine(Canvas canvas, Offset center, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - 6)
      ..lineTo(center.dx - 4, center.dy + 4)
      ..lineTo(center.dx + 4, center.dy + 4)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
