import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

enum AiButtonType { solid, outline, text }

class AiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final AiButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AiButtonType.solid,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.s),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.s),
        ],
        Text(label, style: AppTypographyTokens.bodyStrong),
      ],
    );

    switch (type) {
      case AiButtonType.solid:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorTokens.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.l),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
          ),
          child: buttonChild,
        );
      case AiButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColorTokens.primary,
            side: const BorderSide(color: AppColorTokens.divider),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.l),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
          ),
          child: buttonChild,
        );
      case AiButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColorTokens.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusS),
          ),
          child: buttonChild,
        );
    }
  }
}
