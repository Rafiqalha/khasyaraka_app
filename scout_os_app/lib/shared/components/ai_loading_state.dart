import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AiLoadingState extends StatelessWidget {
  final String message;

  const AiLoadingState({
    super.key,
    this.message = 'AI Core Processing...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppColorTokens.primary,
                strokeWidth: 3,
                backgroundColor: AppColorTokens.surface,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypographyTokens.bodyStrong.copyWith(
                color: AppColorTokens.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
