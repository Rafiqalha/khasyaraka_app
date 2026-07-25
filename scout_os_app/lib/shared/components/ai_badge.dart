import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

enum AiBadgeStatus { info, success, warning, danger }

class AiBadge extends StatelessWidget {
  final String label;
  final AiBadgeStatus status;
  final IconData? icon;

  const AiBadge({
    super.key,
    required this.label,
    this.status = AiBadgeStatus.info,
    this.icon,
  });

  Color _getBackgroundColor() {
    switch (status) {
      case AiBadgeStatus.info:
        return AppColorTokens.primaryLight;
      case AiBadgeStatus.success:
        return AppColorTokens.success.withValues(alpha: 0.1);
      case AiBadgeStatus.warning:
        return AppColorTokens.warning.withValues(alpha: 0.1);
      case AiBadgeStatus.danger:
        return AppColorTokens.danger.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case AiBadgeStatus.info:
        return AppColorTokens.primaryDark;
      case AiBadgeStatus.success:
        return AppColorTokens.success;
      case AiBadgeStatus.warning:
        return AppColorTokens.warning;
      case AiBadgeStatus.danger:
        return AppColorTokens.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: AppRadius.radiusXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _getTextColor()),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypographyTokens.metadata.copyWith(
              color: _getTextColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
