import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class PathConnectorPainter extends CustomPainter {
  final int nodeCount;
  final double nodeSpacing;

  PathConnectorPainter({required this.nodeCount, required this.nodeSpacing});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCount <= 1) return;

    final paint = Paint()
      ..color = AppColors.textGrey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final nodeRadius = 40.0;
    double currentY = nodeRadius;

    for (int i = 0; i < nodeCount - 1; i++) {
      final startY = currentY;
      final endY = currentY + nodeSpacing;

      final path = Path();
      path.moveTo(centerX, startY);
      path.lineTo(centerX, endY);

      canvas.drawPath(path, paint);
      currentY = endY;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
