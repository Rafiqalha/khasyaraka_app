import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';

class TerminalInput extends StatefulWidget {
  const TerminalInput({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}

class _TerminalInputState extends State<TerminalInput> {
  bool _cursorOn = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _cursorOn = !_cursorOn;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberTheme.primary.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Text(
            "> ",
            style: GoogleFonts.firaCode(
              color: CyberTheme.primary,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onSubmitted: (_) => widget.onSubmitted?.call(),
              style: GoogleFonts.firaCode(
                color: CyberTheme.primary,
                fontSize: 14,
              ),
              cursorColor: CyberTheme.primary,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: "ENTER KEY",
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _cursorOn ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              "_",
              style: GoogleFonts.firaCode(
                color: CyberTheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
