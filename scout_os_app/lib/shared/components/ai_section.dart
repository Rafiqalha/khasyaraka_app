import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AiSection extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget child;
  final Widget? action;

  const AiSection({
    super.key,
    this.title,
    this.description,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null || action != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: AppTypographyTokens.sectionHeading,
                  ),
                ),
              if (action != null) action!,
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description!,
              style: AppTypographyTokens.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.l),
        ],
        child,
      ],
    );
  }
}
