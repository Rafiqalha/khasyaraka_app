import 'package:flutter/material.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/colors.dart';

class SandboxPage extends StatelessWidget {
  const SandboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PradigiSpacing.desktopMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Sandbox",
              style: PradigiTypography.h2,
            ),
            const SizedBox(height: PradigiSpacing.s8),
            Text(
              "Experiment freely. There are no right or wrong answers here.",
              style: PradigiTypography.bodySecondary,
            ),
            const SizedBox(height: PradigiSpacing.s32),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: PradigiColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Interactive Sandbox Environment Placeholder",
                    style: TextStyle(color: PradigiColors.surface),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PradigiSpacing.s24),
          ],
        ),
      ),
    );
  }
}
