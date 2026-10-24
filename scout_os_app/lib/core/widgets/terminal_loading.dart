import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';

class TerminalLoading extends StatefulWidget {
  final Color? color;
  final double fontSize;
  
  const TerminalLoading({
    super.key,
    this.color,
    this.fontSize = 14,
  });

  @override
  State<TerminalLoading> createState() => _TerminalLoadingState();
}

class _TerminalLoadingState extends State<TerminalLoading> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4; // 0, 1, 2, 3
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    return SizedBox(
      width: 100,
      child: Text(
        'Loading$dots',
        style: PradigiTypography.code.copyWith(
          color: widget.color ?? PradigiColors.primary,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
