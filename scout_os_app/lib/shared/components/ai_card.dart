import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isInteractive;

  const AiCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColorTokens.card,
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: AppColorTokens.divider),
        boxShadow: AppElevation.softShadow,
      ),
      child: child,
    );

    if (onTap != null || isInteractive) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusM,
          hoverColor: AppColorTokens.primaryLight.withValues(alpha: 0.1),
          highlightColor: AppColorTokens.primaryLight.withValues(alpha: 0.2),
          child: card,
        ),
      );
    }

    return card;
  }
}
