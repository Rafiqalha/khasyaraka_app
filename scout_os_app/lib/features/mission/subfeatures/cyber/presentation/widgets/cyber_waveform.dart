import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';

class CyberWaveform extends StatefulWidget {
  const CyberWaveform({
    super.key,
    required this.isPlaying,
    this.isError = false,
    this.height = 60,
  });

  final bool isPlaying;
  final bool isError;
  final double height;

  @override
  State<CyberWaveform> createState() => _CyberWaveformState();
}

class _CyberWaveformState extends State<CyberWaveform> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CyberWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              isPlaying: widget.isPlaying,
              isError: widget.isError,
              seed: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.isPlaying, required this.isError, required this.seed});

  final bool isPlaying;
  final bool isError;
  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final baseLine = size.height / 2;
    final paintLine = Paint()
      ..color = isError ? CyberTheme.error : CyberTheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintAccent = Paint()
      ..color = CyberTheme.primary.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, baseLine);

    if (!isPlaying) {
      path.lineTo(size.width, baseLine);
      canvas.drawPath(path, paintLine);
      return;
    }

    final random = Random((seed * 1000).round());
    const int spikes = 28;
    final double step = size.width / spikes;

    for (int i = 1; i <= spikes; i++) {
      final x = step * i;
      final spikeHeight = (random.nextDouble() * 0.8 + 0.2) * (size.height / 2.4);
      final direction = random.nextBool() ? 1 : -1;
      final y = baseLine + (spikeHeight * direction);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paintLine);

    final accentPath = Path();
    accentPath.moveTo(0, baseLine);
    for (int i = 1; i <= spikes; i++) {
      final x = step * i;
      final jitter = (random.nextDouble() * 0.4 - 0.2) * (size.height / 2.4);
      accentPath.lineTo(x, baseLine + jitter);
    }
    canvas.drawPath(accentPath, paintAccent);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.isError != isError;
  }
}
