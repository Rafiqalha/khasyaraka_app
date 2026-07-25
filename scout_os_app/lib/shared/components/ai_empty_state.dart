import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AiEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? action;

  const AiEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColorTokens.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColorTokens.divider),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColorTokens.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypographyTokens.sectionHeading,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: AppTypographyTokens.body.copyWith(
                color: AppColorTokens.textSecondary,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            action!,
          ],
        ],
      ),
    );
  }
}
