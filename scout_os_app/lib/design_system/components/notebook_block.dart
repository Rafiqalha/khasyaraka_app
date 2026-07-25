import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

/// A signature component for Pradigi: Notebook Block.
/// 
/// Enforces the Vertical Rhythm: Title -> Short Explanation -> Visual -> Micro Question -> Code -> Continue
class NotebookBlock extends StatelessWidget {
  final String title;
  final String explanation;
  final Widget? visual;
  final String? microQuestion;
  final String? codeSnippet;
  final VoidCallback? onContinue;
  final String continueText;

  const NotebookBlock({
    super.key,
    required this.title,
    required this.explanation,
    this.visual,
    this.microQuestion,
    this.codeSnippet,
    this.onContinue,
    this.continueText = "Continue",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          title,
          style: PradigiTypography.h2,
        ),
        const SizedBox(height: PradigiSpacing.headingToParagraph),
        
        // Short Explanation
        Text(
          explanation,
          style: PradigiTypography.body,
        ),
        
        // Visual / Diagram (Optional)
        if (visual != null) ...[
          const SizedBox(height: PradigiSpacing.paragraphToDiagram),
          visual!,
        ],
        
        // Micro Question (Optional)
        if (microQuestion != null) ...[
          const SizedBox(height: PradigiSpacing.diagramToQuestion),
          Container(
            padding: const EdgeInsets.all(PradigiSpacing.s24),
            decoration: BoxDecoration(
              color: PradigiColors.background,
              borderRadius: BorderRadius.circular(PradigiRadius.r16),
              border: Border.all(color: PradigiColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: PradigiColors.primary),
                const SizedBox(width: PradigiSpacing.s16),
                Expanded(
                  child: Text(
                    microQuestion!,
                    style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Code Snippet (Optional)
        if (codeSnippet != null) ...[
          const SizedBox(height: PradigiSpacing.s24),
          Container(
            padding: const EdgeInsets.all(PradigiSpacing.s24),
            decoration: BoxDecoration(
              color: PradigiColors.textPrimary, // Dark background for code
              borderRadius: BorderRadius.circular(PradigiRadius.r16),
            ),
            child: Text(
              codeSnippet!,
              style: PradigiTypography.code.copyWith(color: PradigiColors.surface),
            ),
          ),
        ],

        // Primary Action (Optional, usually handled by shell)
        if (onContinue != null) ...[
          const SizedBox(height: PradigiSpacing.questionToButton),
          FilledButton(
            onPressed: onContinue,
            child: Text(continueText),
          ),
        ]
      ],
    );
  }
}
