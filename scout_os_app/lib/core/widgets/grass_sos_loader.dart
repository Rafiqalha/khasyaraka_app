import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';

// ==========================================
// SANDI RUMPUT SOS LOADER (SHARED CORE WIDGET)
// ==========================================
class GrassSosLoader extends StatefulWidget {
  final Color color;

  const GrassSosLoader({
    super.key,
    this.color = const Color(0xFFFFD600), // Scout Gold by default
  });

  @override
  State<GrassSosLoader> createState() => _GrassSosLoaderState();
}

class _GrassSosLoaderState extends State<GrassSosLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 60,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _GrassSosPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _GrassSosPainter extends CustomPainter {
  final double progress;
  final Color color;

  _GrassSosPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final baseline = height;

    // Define unit widths
    // SOS Pattern: ... --- ...
    // S (...) = 3 short peaks
    // O (---) = 3 tall peaks
    // S (...) = 3 short peaks
    // Total "units" approx: (3*1 + 2 gaps) + space + (3*1.5 + 2 gaps) + space + (3*1 + 2 gaps)

    double unitWidth = width / 15; // Rough estimation for spacing

    // Helper to draw a peak
    void drawPeak(double peakHeight) {
      path.relativeLineTo(unitWidth / 2, -peakHeight);
      path.relativeLineTo(unitWidth / 2, peakHeight);
    }

    void drawGap() {
      path.relativeLineTo(unitWidth / 2, 0);
    }

    path.moveTo(0, baseline);

    // --- Draw S (...) ---
    drawPeak(height * 0.4);
    drawPeak(height * 0.4);
    drawPeak(height * 0.4);
    drawGap();
    drawGap();

    // --- Draw O (---) ---
    drawPeak(height * 0.9);
    drawPeak(height * 0.9);
    drawPeak(height * 0.9);
    drawGap();
    drawGap();

    // --- Draw S (...) ---
    drawPeak(height * 0.4);
    drawPeak(height * 0.4);
    drawPeak(height * 0.4);

    // Background Trace (Faint)
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawPath(path, bgPaint);

    // Foreground Animation (Drawing)
    final pathMetrics = path.computeMetrics();
    final extractPath = Path();

    for (var metric in pathMetrics) {
      extractPath.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _GrassSosPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
