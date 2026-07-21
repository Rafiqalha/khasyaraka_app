import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/journey_controller.dart';
import '../../domain/models/journey_node.dart';
import '../pages/pre_assessment_page.dart';
import '../pages/journey_map_page.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';

class LearningShellPage extends ConsumerWidget {
  const LearningShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyState = ref.watch(journeyProvider);
    final currentNode = journeyState.currentNode;

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
                child: _buildNodeContent(currentNode.type),
              ),
            ),
            
            // Bottom CTA
            _buildBottomCTA(context, ref, journeyState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, JourneyState state) {
    final progress = (state.currentIndex + 1) / state.nodes.length;
    
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
            "${state.currentIndex + 1}/${state.nodes.length}",
            style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeContent(NodeType type) {
    switch (type) {
      case NodeType.preAssessment:
        return const PreAssessmentPage();
      case NodeType.journeyMap:
        return const JourneyMapPage();
      default:
        return Center(
          child: Text(
            "Node type $type not implemented yet",
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
                    // Complete journey logic
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
