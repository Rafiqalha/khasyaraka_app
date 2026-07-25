import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AiInput extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;

  const AiInput({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypographyTokens.bodyStrong.copyWith(color: AppColorTokens.textPrimary),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          style: AppTypographyTokens.body,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            // Theme handles the rest of the borders/colors from app_theme.dart
          ),
        ),
      ],
    );
  }
}
