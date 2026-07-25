import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/theme/design_tokens.dart';

/// Enterprise-grade Capability Radar Chart using CustomPaint.
/// No third-party chart library — clean, mathematical rendering.
class CapabilityRadarChart extends StatefulWidget {
  final Map<String, double> capabilities; // values 0.0 – 100.0
  final Color? accentColor;

  const CapabilityRadarChart({
    super.key,
    required this.capabilities,
    this.accentColor,
  });

  @override
  State<CapabilityRadarChart> createState() => _CapabilityRadarChartState();
}

class _CapabilityRadarChartState extends State<CapabilityRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColorTokens.primary;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _RadarPainter(
            data: widget.capabilities,
            progress: _animation.value,
            accentColor: color,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, double> data;
  final double progress;
  final Color accentColor;

  _RadarPainter({
    required this.data,
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 32;
    final entries = data.entries.toList();
    final count = entries.length;
    const gridLevels = 5;
    const startAngle = -math.pi / 2;

    // ── Grid Lines ──────────────────────────────────────
    final gridPaint = Paint()
      ..color = AppColorTokens.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int level = 1; level <= gridLevels; level++) {
      final levelRadius = radius * level / gridLevels;
      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = startAngle + (2 * math.pi * i / count);
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // ── Axis Lines ──────────────────────────────────────
    final axisPaint = Paint()
      ..color = AppColorTokens.divider
      ..strokeWidth = 1.0;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + (2 * math.pi * i / count);
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        axisPaint,
      );
    }

    // ── Filled Polygon (Capability Area) ───────────────
    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final dataPath = Path();
    for (int i = 0; i < count; i++) {
      final angle = startAngle + (2 * math.pi * i / count);
      final normalizedValue = (entries[i].value.clamp(0.0, 100.0) / 100.0) * progress;
      final r = radius * normalizedValue;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // ── Data Point Dots ─────────────────────────────────
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + (2 * math.pi * i / count);
      final normalizedValue = (entries[i].value.clamp(0.0, 100.0) / 100.0) * progress;
      final r = radius * normalizedValue;
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)),
        4.0,
        dotPaint,
      );
    }

    // ── Axis Labels ─────────────────────────────────────
    final textStyle = TextStyle(
      color: AppColorTokens.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    for (int i = 0; i < count; i++) {
      final angle = startAngle + (2 * math.pi * i / count);
      final labelRadius = radius + 22;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final textSpan = TextSpan(text: entries[i].key.toUpperCase(), style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.data != data;
}
