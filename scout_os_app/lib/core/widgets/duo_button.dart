import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/radius.dart';

enum DuoButtonVariant { green, blue, red, white, outline }

/// Modernized button maintaining API compatibility with legacy code
/// while adopting the Pradigi minimalist design system aesthetics.
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
    this.height = 48.0,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  Color get _backgroundColor {
    if (widget.onPressed == null) return const Color(0xFFE2E8F0);
    switch (widget.variant) {
      case DuoButtonVariant.green:
        return PradigiColors.success;
      case DuoButtonVariant.blue:
        return PradigiColors.primary;
      case DuoButtonVariant.red:
        return PradigiColors.danger;
      case DuoButtonVariant.white:
      case DuoButtonVariant.outline:
        return PradigiColors.surface;
    }
  }

  Color get _textColor {
    if (widget.onPressed == null) return const Color(0xFF94A3B8);
    switch (widget.variant) {
      case DuoButtonVariant.green:
      case DuoButtonVariant.blue:
      case DuoButtonVariant.red:
        return Colors.white;
      case DuoButtonVariant.white:
      case DuoButtonVariant.outline:
        return PradigiColors.textPrimary;
    }
  }

  Color get _borderColor {
    if (widget.onPressed == null) return Colors.transparent;
    if (widget.variant == DuoButtonVariant.outline || widget.variant == DuoButtonVariant.white) {
      return PradigiColors.border;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.height,
      child: Material(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(PradigiRadius.r14),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(PradigiRadius.r14),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PradigiRadius.r14),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20, color: _textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    color: _textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
