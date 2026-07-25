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
        // Top Mission Info (No Card)
        Text("MISSION", style: PradigiTypography.caption.copyWith(color: PradigiColors.textSecondary, letterSpacing: 2.0, fontWeight: FontWeight.w600)),
        const SizedBox(height: PradigiSpacing.s8),
        Text(missionTitle, style: PradigiTypography.h2),
        const SizedBox(height: PradigiSpacing.s24),
        
        // Meta Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMeta("Estimated", estimatedTime),
            _buildMeta("Difficulty", difficulty),
            _buildMeta("Concept", concept),
          ],
        ),
        const SizedBox(height: PradigiSpacing.s32),
        
        Text("Objective", style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: PradigiSpacing.s8),
        Text(objective, style: PradigiTypography.body),
        
        const SizedBox(height: PradigiSpacing.s32),
        
        // Editor Panel
        Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            color: PradigiColors.editorBackground,
            borderRadius: BorderRadius.circular(PradigiRadius.r12),
            border: Border.all(color: PradigiColors.editorBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fake IDE Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: PradigiSpacing.s16, vertical: PradigiSpacing.s8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: PradigiColors.editorBorder, width: 1)),
                ),
                child: Text("main.py", style: PradigiTypography.caption.copyWith(color: PradigiColors.textSecondary)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(PradigiRadius.r12)),
                  child: editorWidget,
                ),
              ),
            ],
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
           const SizedBox(height: PradigiSpacing.s16),
           FilledButton(
             onPressed: onContinue,
             child: const Text("Continue →"),
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
        const SizedBox(height: PradigiSpacing.s8),
        Text(value, style: PradigiTypography.body.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildResultPanel() {
    if (status == MissionConsoleStatus.idle || status == MissionConsoleStatus.running) {
      return const SizedBox.shrink();
    }

    if (status == MissionConsoleStatus.passed) {
       return Align(
         alignment: Alignment.centerLeft,
         child: Container(
           width: double.infinity,
           padding: const EdgeInsets.symmetric(horizontal: PradigiSpacing.s24, vertical: 16),
           decoration: BoxDecoration(
             color: PradigiColors.successLight,
             borderRadius: BorderRadius.circular(PradigiRadius.r16),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.check_circle, color: PradigiColors.success, size: 24),
                   const SizedBox(width: PradigiSpacing.s8),
                   Text("Mission Passed!", style: PradigiTypography.h3.copyWith(color: PradigiColors.success)),
                 ],
               ),
               const SizedBox(height: PradigiSpacing.s16),
               Row(
                 children: [
                   _buildProgressPill("+50 XP", Icons.star, Colors.orange),
                   const SizedBox(width: PradigiSpacing.s12),
                   _buildProgressPill("Python Basics +12%", Icons.trending_up, PradigiColors.primary),
                   const SizedBox(width: PradigiSpacing.s12),
                   _buildProgressPill("Goal 42%", Icons.flag, Colors.purple),
                 ],
               )
             ],
           ),
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
             const SizedBox(height: PradigiSpacing.s8),
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

  Widget _buildProgressPill(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(PradigiRadius.rFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
