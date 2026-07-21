import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/journey_controller.dart';
import '../../domain/entities/learning_entities.dart';
import '../pages/pre_assessment_page.dart';
import '../pages/journey_map_page.dart';
import '../pages/notebook_page.dart';
import '../pages/mission_page.dart';
import '../pages/thinking_page.dart';
import '../pages/quick_check_page.dart';
import '../pages/sandbox_page.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';

class LearningShellPage extends ConsumerWidget {
  const LearningShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyState = ref.watch(journeyProvider);

    if (journeyState.isLoading) {
      return const Scaffold(
        backgroundColor: PradigiColors.background,
        body: Center(child: CircularProgressIndicator(color: PradigiColors.primary)),
      );
    }

    if (journeyState.errorMessage != null) {
      return Scaffold(
        backgroundColor: PradigiColors.background,
        body: Center(
          child: Text(
            "Error loading journey: ${journeyState.errorMessage}",
            style: PradigiTypography.body.copyWith(color: PradigiColors.danger),
          ),
        ),
      );
    }

    final currentNode = journeyState.currentNode;
    if (currentNode == null) {
      return const Scaffold(
        backgroundColor: PradigiColors.background,
        body: Center(child: Text("No content available.", style: PradigiTypography.bodySecondary)),
      );
    }

    return Scaffold(
      backgroundColor: PradigiColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            _buildProgressHeader(context, journeyState),
            
            // Current Node Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PradigiSpacing.mobileContentPadding),
                child: _buildNodeContent(currentNode),
              ),
            ),
            
            // Bottom CTA
            if (currentNode.type != NodeType.mission && currentNode.type != NodeType.thinking)
              _buildBottomCTA(context, ref, journeyState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, JourneyState state) {
    final totalNodes = state.journey?.nodes.length ?? 1;
    final progress = (state.currentIndex + 1) / totalNodes;
    
    return Container(
      padding: const EdgeInsets.all(PradigiSpacing.s16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PradigiColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.close, color: PradigiColors.textSecondary),
          const SizedBox(width: PradigiSpacing.s16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: PradigiColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(PradigiColors.primary),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: PradigiSpacing.s16),
          Text(
            "${state.currentIndex + 1}/$totalNodes",
            style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeContent(JourneyNode node) {
    switch (node.type) {
      case NodeType.preAssessment:
        return const PreAssessmentPage();
      case NodeType.journeyMap:
        return const JourneyMapPage();
      case NodeType.notebook:
        return NotebookPage(nodeId: node.id);
      case NodeType.mission:
        return MissionPage(nodeId: node.id);
      case NodeType.thinking:
        return const ThinkingPage();
      case NodeType.quickCheck:
        return const QuickCheckPage();
      case NodeType.sandbox:
        return const SandboxPage();
      default:
        return Center(
          child: Text(
            "Node type ${node.type} not implemented yet",
            style: PradigiTypography.bodySecondary,
          ),
        );
    }
  }

  Widget _buildBottomCTA(BuildContext context, WidgetRef ref, JourneyState state) {
    return Container(
      padding: const EdgeInsets.all(PradigiSpacing.s24),
      decoration: const BoxDecoration(
        color: PradigiColors.surface,
        border: Border(top: BorderSide(color: PradigiColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: state.hasNext 
                ? () => ref.read(journeyProvider.notifier).nextNode()
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Journey Complete!")),
                    );
                  },
              child: Text(state.hasNext ? "Continue" : "Finish Journey"),
            ),
          ],
        ),
      ),
    );
  }
}
