import 'package:flutter/material.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/colors.dart';

class PreAssessmentPage extends StatelessWidget {
  const PreAssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PradigiSpacing.desktopMaxWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Pre-Assessment",
              style: PradigiTypography.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PradigiSpacing.s24),
            Text(
              "We need to calibrate your starting knowledge before the journey begins.",
              style: PradigiTypography.body.copyWith(color: PradigiColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PradigiSpacing.s48),
            Container(
              padding: const EdgeInsets.all(PradigiSpacing.s32),
              decoration: BoxDecoration(
                color: PradigiColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PradigiColors.border),
              ),
              child: const Text(
                "Assessment Component Placeholder",
                textAlign: TextAlign.center,
                style: PradigiTypography.bodySecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
