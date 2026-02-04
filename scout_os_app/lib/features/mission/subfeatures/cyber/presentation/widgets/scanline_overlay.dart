import 'package:flutter/material.dart';

class ScanlineOverlay extends StatefulWidget {
  const ScanlineOverlay({super.key});

  @override
  State<ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<ScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScanlinePainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const double spacing = 6;
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final sweepY = size.height * progress;
    final sweepPaint = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.12)
      ..strokeWidth = 2.2;
    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
