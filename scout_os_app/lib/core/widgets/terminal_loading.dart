import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalLoading extends StatefulWidget {
  final Color? color;
  final double fontSize;
  
  const TerminalLoading({
    super.key,
    this.color,
    this.fontSize = 16,
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
    // We pad right so the width doesn't jump around
    return SizedBox(
      width: 100, // Fixed width to prevent jumping
      child: Text(
        'Loading$dots',
        style: GoogleFonts.nunito(
          color: widget.color ?? const Color(0xFF00F0FF), // Cyber blue default
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
