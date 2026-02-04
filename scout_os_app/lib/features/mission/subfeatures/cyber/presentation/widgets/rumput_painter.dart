import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Custom Painter for drawing Rumput (Grass) patterns
/// 
/// Features:
/// - Anti-aliasing enabled
/// - Gradient fill (green transparent to bottom)
/// - Variable stroke width (thicker at bottom)
/// - Round line joins for smooth appearance
/// - Path tracing animation support
class RumputPainter extends CustomPainter {
  final String pattern;
  final double animationProgress; // 0.0 to 1.0 for drawing animation
  final Color rumputColor;

  RumputPainter({
    required this.pattern,
    this.animationProgress = 1.0,
    this.rumputColor = const Color(0xFF00FF88), // matrixGreen
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern.trim().isEmpty) return;

    final lines = pattern.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;

    // Calculate cell size based on available space
    final lineHeight = size.height / lines.length;
    final maxLineWidth = lines.map((l) => l.length).reduce((a, b) => a > b ? a : b);
    final charWidth = size.width / maxLineWidth;

    // Enable anti-aliasing
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round // Round joins for smooth appearance
      ..strokeCap = StrokeCap.round;

    // Calculate total characters for animation
    int totalChars = 0;
    for (var line in lines) {
      for (var char in line.split('')) {
        if (char == '|') totalChars++;
      }
    }

    int currentCharIndex = 0;

    // Draw each line
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final lineY = lineIndex * lineHeight + lineHeight * 0.5;

      // Calculate stroke width (thicker at bottom)
      final baseStrokeWidth = 2.5;
      final bottomWeight = (lineIndex + 1) / lines.length; // 0.0 to 1.0
      final strokeWidth = baseStrokeWidth + (bottomWeight * 2.5); // 2.5 to 5.0

      // Draw each character in the line
      for (int charIndex = 0; charIndex < line.length; charIndex++) {
        final char = line[charIndex];
        final charX = charIndex * charWidth + charWidth * 0.5;

        if (char == '|') {
          // Calculate animation progress for this character
          final charProgress = (currentCharIndex + 1) / totalChars;
          final shouldDraw = charProgress <= animationProgress;

          if (shouldDraw) {
            // Draw rumput blade (vertical line with gradient fill)
            _drawRumputBlade(
              canvas,
              Offset(charX, lineY),
              charWidth * 0.4, // Width of blade
              lineHeight * 0.7, // Height of blade
              strokeWidth,
              paint,
            );
          }
          
          currentCharIndex++;
        }
      }
    }
  }

  /// Draw a single rumput blade with gradient fill
  void _drawRumputBlade(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double strokeWidth,
    Paint paint,
  ) {
    // Create path for rumput blade (vertical line, slightly curved)
    final path = Path();
    
    // Top point (narrow, sharp)
    final top = Offset(center.dx, center.dy - height * 0.5);
    
    // Bottom points (wider, thicker)
    final bottomLeft = Offset(center.dx - width * 0.4, center.dy + height * 0.5);
    final bottomRight = Offset(center.dx + width * 0.4, center.dy + height * 0.5);
    
    // Create blade shape (vertical line with slight curve)
    path.moveTo(top.dx, top.dy);
    
    // Left side with slight curve
    path.quadraticBezierTo(
      center.dx - width * 0.1,
      center.dy,
      bottomLeft.dx,
      bottomLeft.dy,
    );
    
    // Bottom line
    path.lineTo(bottomRight.dx, bottomRight.dy);
    
    // Right side with slight curve back to top
    path.quadraticBezierTo(
      center.dx + width * 0.1,
      center.dy,
      top.dx,
      top.dy,
    );
    
    path.close();

    // Draw gradient fill (green transparent to bottom)
    final gradient = ui.Gradient.linear(
      Offset(center.dx, center.dy - height * 0.5), // Top
      Offset(center.dx, center.dy + height * 0.5), // Bottom
      [
        rumputColor.withOpacity(0.9), // Top: more opaque
        rumputColor.withOpacity(0.2), // Bottom: more transparent
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, fillPaint);

    // Draw stroke (outline) with variable width
    paint.color = rumputColor;
    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RumputPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.rumputColor != rumputColor;
  }
}
