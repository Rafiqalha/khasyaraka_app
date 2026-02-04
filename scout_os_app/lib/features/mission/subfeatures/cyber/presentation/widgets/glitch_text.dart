import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';

class GlitchText extends StatefulWidget {
  const GlitchText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 2,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  bool _glitchOn = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      setState(() {
        _glitchOn = !_glitchOn;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? CyberTheme.body();
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          widget.text,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
          style: baseStyle,
          textAlign: TextAlign.center,
        ),
        if (_glitchOn) ...[
          Transform.translate(
            offset: const Offset(1.5, -1),
            child: Text(
              widget.text,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
              style: baseStyle.copyWith(color: CyberTheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          Transform.translate(
            offset: const Offset(-1.5, 1),
            child: Text(
              widget.text,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
              style: baseStyle.copyWith(color: CyberTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
