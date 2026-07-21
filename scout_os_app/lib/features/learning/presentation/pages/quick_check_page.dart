import 'package:flutter/material.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/colors.dart';

class QuickCheckPage extends StatelessWidget {
  const QuickCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PradigiSpacing.desktopMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Quick Check",
              style: PradigiTypography.h2,
            ),
            const SizedBox(height: PradigiSpacing.s8),
            Text(
              "Let's make sure that concept stuck.",
              style: PradigiTypography.bodySecondary,
            ),
            const SizedBox(height: PradigiSpacing.s32),
            
            // Question 1
            Text("1. What is the index of the first element in an array?", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: PradigiSpacing.s16),
            _buildOption("1"),
            _buildOption("0", isSelected: true),
            _buildOption("-1"),
            
            const SizedBox(height: PradigiSpacing.s48),
            
            // Question 2
            Text("2. If an array has 5 elements, what is the last index?", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: PradigiSpacing.s16),
            _buildOption("5"),
            _buildOption("4"),
            _buildOption("6"),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: PradigiSpacing.s8),
      padding: const EdgeInsets.all(PradigiSpacing.s16),
      decoration: BoxDecoration(
        color: isSelected ? PradigiColors.primary.withValues(alpha: 0.1) : PradigiColors.surface,
        border: Border.all(color: isSelected ? PradigiColors.primary : PradigiColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSelected ? PradigiColors.primary : PradigiColors.textSecondary,
          ),
          const SizedBox(width: PradigiSpacing.s16),
          Text(
            text,
            style: PradigiTypography.body.copyWith(
              color: isSelected ? PradigiColors.primary : PradigiColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
