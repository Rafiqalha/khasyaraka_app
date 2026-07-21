import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import '../tokens/radius.dart';

enum MissionConsoleStatus { idle, running, passed, failed }

/// A signature component for Pradigi: Mission Console.
/// 
/// Merges objective and IDE into a cohesive developer-like environment.
class MissionConsole extends StatelessWidget {
  final String missionTitle;
  final String objective;
  final String estimatedTime;
  final String difficulty;
  final String concept;
  
  final Widget editorWidget;
  
  final MissionConsoleStatus status;
  final String? expectedOutput;
  final String? receivedOutput;
  final String? errorReason;
  
  final VoidCallback onRunTests;
  final VoidCallback? onContinue;
  final VoidCallback? onHintRequested;

  const MissionConsole({
    super.key,
    required this.missionTitle,
    required this.objective,
    required this.estimatedTime,
    required this.difficulty,
    required this.concept,
    required this.editorWidget,
    this.status = MissionConsoleStatus.idle,
    this.expectedOutput,
    this.receivedOutput,
    this.errorReason,
    required this.onRunTests,
    this.onContinue,
    this.onHintRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Mission Card Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(PradigiSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mission", style: PradigiTypography.caption.copyWith(color: PradigiColors.primary)),
                const SizedBox(height: PradigiSpacing.s4),
                Text(missionTitle, style: PradigiTypography.h2),
                const SizedBox(height: PradigiSpacing.s16),
                
                // Meta Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMeta("Estimated", estimatedTime),
                    _buildMeta("Difficulty", difficulty),
                    _buildMeta("Concept", concept),
                  ],
                ),
                const SizedBox(height: PradigiSpacing.s24),
                const Divider(),
                const SizedBox(height: PradigiSpacing.s24),
                
                Text("Objective", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: PradigiSpacing.s8),
                Text(objective, style: PradigiTypography.body),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: PradigiSpacing.s24),
        
        // Editor Panel
        Container(
          height: 300, // Fixed or flexible depending on parent
          decoration: BoxDecoration(
            color: PradigiColors.textPrimary, // Dark mode for editor
            borderRadius: BorderRadius.circular(PradigiRadius.r16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PradigiRadius.r16),
            child: editorWidget,
          ),
        ),
        
        const SizedBox(height: PradigiSpacing.s24),
        
        // Run Tests Button
        if (status != MissionConsoleStatus.passed)
          FilledButton.icon(
            onPressed: status == MissionConsoleStatus.running ? null : onRunTests,
            icon: status == MissionConsoleStatus.running 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: PradigiColors.surface)) 
                : const Icon(Icons.play_arrow),
            label: Text(status == MissionConsoleStatus.running ? "Running Tests..." : "Run Tests"),
          ),
          
        const SizedBox(height: PradigiSpacing.s24),
        
        // Output / Result Panel
        _buildResultPanel(),
        
        // Continue Action
        if (status == MissionConsoleStatus.passed && onContinue != null) ...[
           const SizedBox(height: PradigiSpacing.s24),
           FilledButton(
             style: FilledButton.styleFrom(backgroundColor: PradigiColors.success),
             onPressed: onContinue,
             child: const Text("Continue"),
           ),
        ]
      ],
    );
  }

  Widget _buildMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PradigiTypography.caption),
        const SizedBox(height: PradigiSpacing.s4),
        Text(value, style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildResultPanel() {
    if (status == MissionConsoleStatus.idle || status == MissionConsoleStatus.running) {
      return const SizedBox.shrink();
    }

    if (status == MissionConsoleStatus.passed) {
       return Container(
         padding: const EdgeInsets.all(PradigiSpacing.s24),
         decoration: BoxDecoration(
           color: PradigiColors.success.withValues(alpha: 0.1),
           borderRadius: BorderRadius.circular(PradigiRadius.r16),
           border: Border.all(color: PradigiColors.success),
         ),
         child: Row(
           children: [
             const Icon(Icons.check_circle, color: PradigiColors.success),
             const SizedBox(width: PradigiSpacing.s16),
             Text("Tests Passed", style: PradigiTypography.body.copyWith(color: PradigiColors.success, fontWeight: FontWeight.bold)),
           ],
         ),
       );
    }

    // Failed
    return Container(
      padding: const EdgeInsets.all(PradigiSpacing.s24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light pastel red as specified
        borderRadius: BorderRadius.circular(PradigiRadius.r16),
        border: Border.all(color: PradigiColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: PradigiColors.danger),
                  const SizedBox(width: PradigiSpacing.s16),
                  Text("Test Failed", style: PradigiTypography.body.copyWith(color: PradigiColors.danger, fontWeight: FontWeight.bold)),
                ],
              ),
              if (onHintRequested != null)
                TextButton.icon(
                  onPressed: onHintRequested,
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: const Text("Need a hint?"),
                )
            ],
          ),
          if (expectedOutput != null || receivedOutput != null) ...[
             const SizedBox(height: PradigiSpacing.s16),
             Text("Expected : ${expectedOutput ?? '-'}", style: PradigiTypography.code.copyWith(color: PradigiColors.textPrimary)),
             const SizedBox(height: PradigiSpacing.s4),
             Text("Received : ${receivedOutput ?? '-'}", style: PradigiTypography.code.copyWith(color: PradigiColors.danger)),
          ],
          if (errorReason != null) ...[
             const SizedBox(height: PradigiSpacing.s16),
             Text(errorReason!, style: PradigiTypography.bodySecondary.copyWith(color: PradigiColors.danger)),
          ]
        ],
      ),
    );
  }
}
