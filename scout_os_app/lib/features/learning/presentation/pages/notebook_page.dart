import 'package:flutter/material.dart';
import '../../../../design_system/components/notebook_block.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../core/telemetry/telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';

class NotebookPage extends ConsumerStatefulWidget {
  final String nodeId;
  const NotebookPage({super.key, required this.nodeId});

  @override
  ConsumerState<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends ConsumerState<NotebookPage> {
  bool _hasInteracted = false;
  String? _selectedAnswer1;
  String? _selectedAnswer2;

  void _handleMicroInteraction() {
    setState(() {
      _hasInteracted = true;
    });
    Telemetry.track(
      event: CognitiveEvent.activityCompleted,
      payload: {'nodeId': widget.nodeId, 'action': 'reveal_code'},
    );
  }

  void _checkCompletion() {
    if (_selectedAnswer1 == "0" && _selectedAnswer2 == "4") {
      ref.read(journeyProvider.notifier).completeNode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NotebookBlock(
                title: "What is an Array?",
                explanation: "An array is a linear collection of elements, accessed via indices. The most common pitfall is the 'Off-by-One' error.",
                visual: Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.withAlpha(20),
                  child: const Center(child: Text("Interactive Array Memory Visualizer")),
                ),
                microQuestion: "Click here to reveal the code snippet below.",
                codeSnippet: _hasInteracted ? "arr = [1, 2, 3]\nprint(arr[0])" : null,
                onContinue: _hasInteracted ? null : _handleMicroInteraction,
                continueText: "Reveal Code",
              ),
              
              if (_hasInteracted) ...[
                const SizedBox(height: PradigiSpacing.s48),
                const Divider(color: PradigiColors.border),
                const SizedBox(height: PradigiSpacing.s32),
                Text("Quick Check", style: PradigiTypography.h2),
                const SizedBox(height: PradigiSpacing.s8),
                Text("Let's make sure that concept stuck.", style: PradigiTypography.bodySecondary),
                const SizedBox(height: PradigiSpacing.s32),
                
                // Question 1
                Text("1. What is the index of the first element in an array?", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: PradigiSpacing.s16),
                _buildOption(1, "1", _selectedAnswer1 == "1"),
                _buildOption(1, "0", _selectedAnswer1 == "0"),
                _buildOption(1, "-1", _selectedAnswer1 == "-1"),
                
                const SizedBox(height: PradigiSpacing.s48),
                
                // Question 2
                Text("2. If an array has 5 elements, what is the last index?", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: PradigiSpacing.s16),
                _buildOption(2, "5", _selectedAnswer2 == "5"),
                _buildOption(2, "4", _selectedAnswer2 == "4"),
                _buildOption(2, "6", _selectedAnswer2 == "6"),
                
                const SizedBox(height: PradigiSpacing.s48),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int questionNum, String text, bool isSelected) {
    bool isCorrect = false;
    bool isWrong = false;
    
    // Only show correctness if it's selected
    if (isSelected) {
      if (questionNum == 1) {
        isCorrect = text == "0";
        isWrong = text != "0";
      } else {
        isCorrect = text == "4";
        isWrong = text != "4";
      }
    }

    final borderColor = isCorrect ? PradigiColors.success : (isWrong ? PradigiColors.danger : (isSelected ? PradigiColors.primary : PradigiColors.border));
    final bgColor = isCorrect ? PradigiColors.successLight : (isWrong ? const Color(0xFFFEF2F2) : (isSelected ? PradigiColors.primary.withValues(alpha: 0.1) : PradigiColors.surface));
    final iconColor = isCorrect ? PradigiColors.success : (isWrong ? PradigiColors.danger : (isSelected ? PradigiColors.primary : PradigiColors.textSecondary));
    final textColor = isCorrect ? PradigiColors.success : (isWrong ? PradigiColors.danger : (isSelected ? PradigiColors.primary : PradigiColors.textPrimary));
    final icon = isCorrect ? Icons.check_circle : (isWrong ? Icons.cancel : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked));

    return GestureDetector(
      onTap: () {
        setState(() {
          if (questionNum == 1) _selectedAnswer1 = text;
          if (questionNum == 2) _selectedAnswer2 = text;
        });
        _checkCompletion();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: PradigiSpacing.s8),
        padding: const EdgeInsets.all(PradigiSpacing.s16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: PradigiSpacing.s16),
            Text(
              text,
              style: PradigiTypography.body.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
