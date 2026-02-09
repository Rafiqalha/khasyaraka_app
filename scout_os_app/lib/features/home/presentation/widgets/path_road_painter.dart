import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A CustomPainter that draws a soft curved road connecting level nodes.
/// Supports direction flip for alternating unit paths.
class PathRoadPainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;
  final double Function(int index) getOffsetX;
  final Color color;
  final double strokeWidth;
  final double direction; // 1.0 = right-leaning, -1.0 = left-leaning

  PathRoadPainter({
    required this.itemCount,
    required this.itemHeight,
    required this.getOffsetX,
    this.color = const Color(0xFFE8E8E8),
    this.strokeWidth = 12.0,
    this.direction = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final path = Path();

    // Start from the center of the first node (with direction applied)
    final firstX = centerX + (getOffsetX(0) * direction);
    final firstY = itemHeight / 2;
    path.moveTo(firstX, firstY);

    for (int i = 0; i < itemCount - 1; i++) {
      final currentX = centerX + (getOffsetX(i) * direction);
      final currentY = (i * itemHeight) + (itemHeight / 2);
      
      final nextX = centerX + (getOffsetX(i + 1) * direction);
      final nextY = ((i + 1) * itemHeight) + (itemHeight / 2);

      // Control point for smooth curve
      final controlX = (currentX + nextX) / 2;
      final controlY = (currentY + nextY) / 2;

      path.quadraticBezierTo(
        currentX,
        controlY,
        nextX,
        nextY,
      );
    }

    // Draw the road with a soft dashed effect
    _drawSoftDashedPath(canvas, path, paint);
  }

  void _drawSoftDashedPath(Canvas canvas, Path path, Paint paint) {
    // Draw base line (very faint)
    final basePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, basePaint);
    
    // Draw main dotted line
    const double dashLength = 18.0;
    const double gapLength = 12.0;
    
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final segment = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(segment, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathRoadPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
           oldDelegate.color != color ||
           oldDelegate.direction != direction;
  }
}

/// Helper class to generate Duolingo-style path offsets
class PathCurveGenerator {
  /// Generates a more natural, varied zigzag offset
  /// Uses alternating amplitudes for visual interest
  /// [direction]: 1.0 for right-leaning, -1.0 for left-leaning
  static double getOffset(int index, double baseAmplitude, {double direction = 1.0}) {
    // Alternating amplitude pattern: 60 -> 90 -> 70 -> 100 -> repeat
    final amplitudes = [60.0, 90.0, 70.0, 100.0, 55.0, 85.0];
    final amplitude = amplitudes[index % amplitudes.length];
    
    // Use a combination of sine waves for more organic feel
    final primary = math.sin(index * 0.9) * amplitude;
    final secondary = math.cos(index * 0.4) * 15.0; // Slight wobble
    
    return (primary + secondary) * direction;
  }
}
