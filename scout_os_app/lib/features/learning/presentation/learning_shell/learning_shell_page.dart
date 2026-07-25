import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/journey_controller.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/learning_entities.dart';
import '../pages/pre_assessment_page.dart';
import '../pages/journey_map_page.dart';
import '../pages/notebook_page.dart';
import '../pages/mission_page.dart';
import '../pages/sandbox_page.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../controllers/thinking_controller.dart';
import '../../../../design_system/components/thinking_screen.dart';
import '../../../../design_system/components/evidence_card.dart';
import '../../../../design_system/components/competency_toast.dart';
import '../../../../design_system/widgets/skeletons.dart';

class LearningShellPage extends ConsumerWidget {
  const LearningShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyState = ref.watch(journeyProvider);

    if (journeyState.isLoading) {
      return const Scaffold(
        backgroundColor: PradigiColors.background,
        body: SafeArea(child: JourneySkeleton()),
      );
    }

    if (journeyState.failure != null) {
      return Scaffold(
        backgroundColor: PradigiColors.background,
        body: Center(
          child: Text(
            "Error loading journey: ${journeyState.failure!.message}",
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Progress Header
                _buildProgressHeader(context, journeyState),
                
                // Current Node Content
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: PradigiSpacing.contentMaxWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: PradigiSpacing.s24),
                        child: _buildNodeContent(currentNode),
                      ),
                    ),
                  ),
                ),
                
                // Bottom CTA
                if (currentNode.type != NodeType.mission)
                  _buildBottomCTA(context, ref, journeyState),
              ],
            ),
          ),
          
          // Thinking Overlay
          _buildThinkingOverlay(context, ref),
        ],
      ),
    );
  }

  Widget _buildThinkingOverlay(BuildContext context, WidgetRef ref) {
    final thinkingState = ref.watch(thinkingProvider);
    
    // Automatically transition to next node when finished
    ref.listen<ThinkingState>(thinkingProvider, (previous, next) {
      if (next.stage == ThinkingStage.finished && previous?.stage != ThinkingStage.finished) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          ref.read(thinkingProvider.notifier).stop();
          ref.read(journeyProvider.notifier).completeNode();
          ref.read(journeyProvider.notifier).nextNode();
        });
      }
    });

    if (!thinkingState.isActive) return const SizedBox.shrink();

    Widget? evidenceCard;
    Widget? competencyToast;
    String statusMessage = "Analyzing Runtime...";
    List<ThinkingCheckItem> items = [];

    switch (thinkingState.stage) {
      case ThinkingStage.idle:
        return const SizedBox.shrink();
      case ThinkingStage.uploading:
        items = const [
          ThinkingCheckItem(label: "Uploading Code", status: ThinkingCheckItemStatus.analyzing),
          ThinkingCheckItem(label: "Evaluating Output", status: ThinkingCheckItemStatus.pending),
          ThinkingCheckItem(label: "Updating Competency", status: ThinkingCheckItemStatus.pending),
        ];
        break;
      case ThinkingStage.evaluating:
        items = const [
          ThinkingCheckItem(label: "Uploading Code", status: ThinkingCheckItemStatus.completed),
          ThinkingCheckItem(label: "Evaluating Output", status: ThinkingCheckItemStatus.analyzing),
          ThinkingCheckItem(label: "Updating Competency", status: ThinkingCheckItemStatus.pending),
        ];
        break;
      case ThinkingStage.updating_competency:
        items = const [
          ThinkingCheckItem(label: "Uploading Code", status: ThinkingCheckItemStatus.completed),
          ThinkingCheckItem(label: "Evaluating Output", status: ThinkingCheckItemStatus.completed),
          ThinkingCheckItem(label: "Updating Competency", status: ThinkingCheckItemStatus.analyzing),
        ];
        if (thinkingState.response != null && thinkingState.response!.evidence.isNotEmpty) {
           evidenceCard = EvidenceCard(
             observations: ["Completed Mission"], // Simple placeholder
             impacts: const {"Score": "+10%"},
           );
        }
        break;
      case ThinkingStage.background_processing:
        items = const [
          ThinkingCheckItem(label: "Uploading Code", status: ThinkingCheckItemStatus.completed),
          ThinkingCheckItem(label: "Evaluating Output", status: ThinkingCheckItemStatus.analyzing),
          ThinkingCheckItem(label: "Updating Competency", status: ThinkingCheckItemStatus.pending),
        ];
        statusMessage = "High load. Processed in background.";
        break;
      case ThinkingStage.finished:
        items = const [
          ThinkingCheckItem(label: "Uploading Code", status: ThinkingCheckItemStatus.completed),
          ThinkingCheckItem(label: "Evaluating Output", status: ThinkingCheckItemStatus.completed),
          ThinkingCheckItem(label: "Updating Competency", status: ThinkingCheckItemStatus.completed),
        ];
        if (thinkingState.response?.competencyDelta != null) {
          competencyToast = CompetencyToast(
            title: thinkingState.response!.competencyDelta!.competencyName,
            delta: "+${(thinkingState.response!.competencyDelta!.newScore * 100).toInt() - (thinkingState.response!.competencyDelta!.oldScore * 100).toInt()}%",
          );
        }
        break;
    }

    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThinkingOverlay(
            checkItems: items,
            statusMessage: thinkingState.statusText.isNotEmpty ? thinkingState.statusText : statusMessage,
            evidenceCard: evidenceCard,
            competencyToast: competencyToast,
            progress: thinkingState.progress,
          ),
          if (thinkingState.stage == ThinkingStage.background_processing) ...[
            const SizedBox(height: PradigiSpacing.s24),
            FilledButton.icon(
              onPressed: () {
                ref.read(thinkingProvider.notifier).stop();
                // They can navigate away, backend will complete it.
                ref.read(journeyProvider.notifier).resetJourney();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Continue Later"),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, JourneyState state) {
    final totalNodes = state.journey?.nodes.length ?? 1;
    final currentIndex = state.journey?.nodes.indexWhere((n) => n.id == state.currentNodeId) ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PradigiSpacing.s24, vertical: PradigiSpacing.s16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PradigiColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: PradigiSpacing.contentMaxWidth),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, color: PradigiColors.textSecondary, size: 20),
              const SizedBox(width: PradigiSpacing.s24),
              Text(
                "Mission",
                style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.w600, color: PradigiColors.textSecondary, letterSpacing: 1.0),
              ),
              const SizedBox(width: PradigiSpacing.s16),
              Expanded(
                child: Row(
                  children: List.generate(totalNodes, (index) {
                    final isActiveOrPassed = index <= currentIndex;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isActiveOrPassed ? PradigiColors.primary : PradigiColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: PradigiSpacing.s16),
              Text(
                "${currentIndex + 1} of $totalNodes",
                style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold, color: PradigiColors.textPrimary),
              ),
            ],
          ),
        ),
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
              onPressed: (state.hasNext && state.lifecycle == NodeLifecycle.complete)
                ? () => ref.read(journeyProvider.notifier).nextNode()
                : (!state.hasNext && state.lifecycle == NodeLifecycle.complete) 
                  ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: PradigiColors.surface,
                          title: Text("Simulation Complete", style: PradigiTypography.h2),
                          content: Text("You have reached the end of the G1.5 validation simulation.", style: PradigiTypography.body),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref.read(journeyProvider.notifier).resetJourney();
                              },
                              child: const Text("Restart Simulation"),
                            )
                          ],
                        ),
                      );
                    }
                  : null,
              child: Text(state.hasNext ? "Continue" : "Finish Journey"),
            ),
          ],
        ),
      ),
    );
  }
}
