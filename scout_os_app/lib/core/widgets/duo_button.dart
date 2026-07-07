import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DuoButtonVariant { green, blue, red, white, outline }

class DuoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DuoButtonVariant variant;
  final IconData? icon;
  final bool isFullWidth;
  final double height;

  const DuoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = DuoButtonVariant.green,
    this.icon,
    this.isFullWidth = true,
    this.height = 50.0,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  Color get _topColor {
    if (widget.onPressed == null) return Colors.grey.shade400;
    switch (widget.variant) {
      case DuoButtonVariant.green:
        return const Color(0xFF58CC02);
      case DuoButtonVariant.blue:
        return const Color(0xFF1CB0F6);
      case DuoButtonVariant.red:
        return const Color(0xFFFF4B4B);
      case DuoButtonVariant.white:
      case DuoButtonVariant.outline:
        return Colors.white;
    }
  }

  Color get _bottomColor {
    if (widget.onPressed == null) return Colors.grey.shade500;
    switch (widget.variant) {
      case DuoButtonVariant.green:
        return const Color(0xFF58A700);
      case DuoButtonVariant.blue:
        return const Color(0xFF1899D6);
      case DuoButtonVariant.red:
        return const Color(0xFFEA2B2B);
      case DuoButtonVariant.white:
      case DuoButtonVariant.outline:
        return const Color(0xFFE5E5E5);
    }
  }

  Color get _textColor {
    if (widget.onPressed == null) return Colors.white;
    switch (widget.variant) {
      case DuoButtonVariant.green:
      case DuoButtonVariant.blue:
      case DuoButtonVariant.red:
        return Colors.white;
      case DuoButtonVariant.white:
      case DuoButtonVariant.outline:
        return const Color(0xFF4B4B4B);
    }
  }

  Color get _borderColor {
    if (widget.onPressed == null) return Colors.transparent;
    if (widget.variant == DuoButtonVariant.outline) {
      return const Color(0xFFE5E5E5);
    }
    return Colors.transparent;
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double pushDepth = 4.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(
          top: _isPressed ? pushDepth : 0,
          bottom: _isPressed ? 0 : pushDepth,
        ),
        decoration: BoxDecoration(
          color: _topColor,
          borderRadius: BorderRadius.circular(16),
          border: widget.variant == DuoButtonVariant.outline 
              ? Border.all(color: _borderColor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: _bottomColor,
              offset: Offset(0, _isPressed ? 0 : pushDepth),
            ),
          ],
        ),
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: _textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: GoogleFonts.fredoka(
                  color: _textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
