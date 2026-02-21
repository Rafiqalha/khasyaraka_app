import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlitchEffect extends StatefulWidget {
  const GlitchEffect({super.key, required this.child});

  final Widget child;

  @override
  State<GlitchEffect> createState() => _GlitchEffectState();
}

class _GlitchEffectState extends State<GlitchEffect> {
  final Random _random = Random();
  Timer? _timer;
  Timer? _glitchBurstTimer;
  bool _isGlitching = false;
  Offset _jitter = Offset.zero;
  Offset _jitter2 = Offset.zero;
  int _burstTick = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNextGlitch();
  }

  void _scheduleNextGlitch() {
    final delayMs = 1200 + _random.nextInt(800);
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delayMs), _triggerGlitch);
  }

  void _triggerGlitch() {
    setState(() {
      _isGlitching = true;
      _jitter = Offset(
        (_random.nextDouble() * 36) - 18,
        (_random.nextDouble() * 24) - 12,
      );
      _jitter2 = Offset(
        (_random.nextDouble() * 28) - 14,
        (_random.nextDouble() * 18) - 9,
      );
    });
    _burstTick = 0;
    HapticFeedback.vibrate();
    _glitchBurstTimer?.cancel();
    _glitchBurstTimer = Timer.periodic(const Duration(milliseconds: 45), (
      timer,
    ) {
      if (!mounted) return;
      _burstTick += 1;
      setState(() {
        _jitter = Offset(
          (_random.nextDouble() * 40) - 20,
          (_random.nextDouble() * 26) - 13,
        );
        _jitter2 = Offset(
          (_random.nextDouble() * 34) - 17,
          (_random.nextDouble() * 22) - 11,
        );
      });
      if (_burstTick >= 10) {
        timer.cancel();
      }
    });

    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isGlitching = false;
        _jitter = Offset.zero;
        _jitter2 = Offset.zero;
      });
      _glitchBurstTimer?.cancel();
      _scheduleNextGlitch();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glitchBurstTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGlitching) {
      return widget.child;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(-14, 0),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.cyanAccent,
              BlendMode.modulate,
            ),
            child: widget.child,
          ),
        ),
        Transform.translate(
          offset: const Offset(14, 0),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.redAccent,
              BlendMode.modulate,
            ),
            child: widget.child,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -10),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white70,
              BlendMode.screen,
            ),
            child: widget.child,
          ),
        ),
        Transform.translate(offset: _jitter, child: widget.child),
        Transform.translate(offset: _jitter2, child: widget.child),
      ],
    );
  }
}
