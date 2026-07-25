// Pradigi OS — Mission Summary Page
//
// Shown after the user submits all findings. Displays capability
// changes with AI-generated behavioral explanations (Layer 3).
//
// AI NEVER scores. AI ONLY explains. Scores come from Layer 2
// (deterministic rule engine). This page renders both.
//
// Design: calm, white, professional — no celebrations, no fireworks.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/academy_controller.dart';
import '../../data/experiment_001_config.dart';
import '../../../../../shared/theme/design_tokens.dart';
import '../../../../../shared/components/ai_card.dart';
import '../../../../../shared/components/ai_button.dart';
import '../../../../../shared/components/ai_badge.dart';
import '../../../../../core/config/capability_config.dart';

class MissionSummaryPage extends StatelessWidget {
  const MissionSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: Consumer<AcademyController>(
          builder: (context, controller, _) {
            if (controller.assessmentResult == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColorTokens.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.l),
                    Text('Generating assessment...',
                      style: TextStyle(color: AppColorTokens.textSecondary)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  _CompletionBadge(controller: controller),
                  const SizedBox(height: AppSpacing.xxl),
                  _ExperimentRecap(controller: controller),
                  const SizedBox(height: AppSpacing.xl),
                  _BehaviorsObserved(controller: controller),
                  const SizedBox(height: AppSpacing.xxl),
                  _CapabilityChanges(controller: controller),
                  const SizedBox(height: AppSpacing.xxxl),
                  AiButton(
                    label: 'View Full Capability Dashboard',
                    icon: Icons.auto_graph_rounded,
                    isFullWidth: true,
                    onPressed: () {
                      controller.viewDashboard();
                      Navigator.pushNamed(context, '/capability-dashboard');
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AiButton(
                    label: 'Back to Academy',
                    type: AiButtonType.text,
                    isFullWidth: true,
                    onPressed: () {
                      controller.returnToAcademy();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Completion Badge ─────────────────────────────────────────

class _CompletionBadge extends StatelessWidget {
  final AcademyController controller;
  const _CompletionBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    final findings = controller.findings;
    final correct = findings.where((f) => f.isCorrect).length;
    final total = Experiment001.hallucinations.length;
    final injectionCorrect =
        controller.injectionResponse?.isCorrect ?? false;

    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: correct >= total * 0.6
                ? AppColorTokens.success.withAlpha(12)
                : AppColorTokens.warning.withAlpha(12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            correct >= total * 0.6
                ? Icons.check_rounded
                : Icons.arrow_forward_rounded,
            size: 32,
            color: correct >= total * 0.6
                ? AppColorTokens.success
                : AppColorTokens.warning,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text('Experiment Complete', style: AppTypographyTokens.pageHeading),
        const SizedBox(height: AppSpacing.s),
        Text(
          Experiment001.title,
          style: AppTypographyTokens.body.copyWith(
            color: AppColorTokens.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AiBadge(
              label: '$correct/$total verified',
              status: correct >= total * 0.6
                  ? AiBadgeStatus.success
                  : AiBadgeStatus.warning,
              icon: Icons.fact_check_outlined,
            ),
            const SizedBox(width: AppSpacing.s),
            AiBadge(
              label: injectionCorrect ? 'Injection blocked' : 'Injection missed',
              status: injectionCorrect
                  ? AiBadgeStatus.success
                  : AiBadgeStatus.danger,
              icon: injectionCorrect
                  ? Icons.shield_outlined
                  : Icons.shield_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Experiment Recap ────────────────────────────────────────

class _ExperimentRecap extends StatelessWidget {
  final AcademyController controller;
  const _ExperimentRecap({required this.controller});

  @override
  Widget build(BuildContext context) {
    final findings = controller.findings;
    final correct = findings.where((f) => f.isCorrect).length;
    final falsePositives = findings.where((f) => f.isFalsePositive).length;

    return AiCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Results', style: AppTypographyTokens.cardTitle),
          const SizedBox(height: AppSpacing.l),
          _RecapRow(
            label: 'Prompt iterations',
            value: '${controller.promptRevisedAfterGeneration ? 2 : 1}',
          ),
          const SizedBox(height: AppSpacing.s),
          _RecapRow(label: 'Sources reviewed',
            value: '${controller.sourceOpened ? Experiment001.sources.length : 0}'),
          const SizedBox(height: AppSpacing.s),
          _RecapRow(label: 'Hallucinations found',
            value: '$correct of ${Experiment001.hallucinations.length}'),
          const SizedBox(height: AppSpacing.s),
          _RecapRow(label: 'False positives',
            value: '$falsePositives'),
          const SizedBox(height: AppSpacing.s),
          _RecapRow(
            label: 'Injection identified',
            value: controller.injectionResponse?.isCorrect == true
                ? 'Yes' : 'No',
          ),
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  const _RecapRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypographyTokens.body.copyWith(
          color: AppColorTokens.textSecondary, fontSize: 14,
        )),
        Text(value, style: AppTypographyTokens.bodyStrong.copyWith(
          fontSize: 14,
        )),
      ],
    );
  }
}

// ── Behaviors Observed ──────────────────────────────────────

class _BehaviorsObserved extends StatelessWidget {
  final AcademyController controller;
  const _BehaviorsObserved({required this.controller});

  @override
  Widget build(BuildContext context) {
    final allActivated = <String>[];
    for (final cap in CapabilityRegistry.capabilities) {
      allActivated.addAll(controller.activatedSignalNamesFor(cap.id));
    }

    if (allActivated.isEmpty) {
      return const SizedBox.shrink();
    }

    return AiCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('During this experiment you:', style: AppTypographyTokens.cardTitle),
          const SizedBox(height: AppSpacing.m),
          ...allActivated.take(6).map((signal) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_rounded, size: 16,
                    color: AppColorTokens.success),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    signal,
                    style: AppTypographyTokens.body.copyWith(
                      fontSize: 14, height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Capability Changes ──────────────────────────────────────

class _CapabilityChanges extends StatelessWidget {
  final AcademyController controller;
  const _CapabilityChanges({required this.controller});

  @override
  Widget build(BuildContext context) {
    final result = controller.assessmentResult;
    if (result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What changed', style: AppTypographyTokens.sectionHeading),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Capability scores updated based on your behavior during this experiment.',
          style: AppTypographyTokens.caption,
        ),
        const SizedBox(height: AppSpacing.l),

        ...result.deltas.map((delta) {
          if (delta.activatedSignals.isEmpty) return const SizedBox.shrink();

          final displayOld = (delta.oldScore * 100).round();
          final displayNew = (delta.newScore * 100).round();
          final displayDelta = delta.delta >= 0
              ? '+${(delta.delta * 100).round()}'
              : '${(delta.delta * 100).round()}';
          final isPositive = delta.delta > 0;
          final isNegative = delta.delta < 0;
          final explanation = controller.generateExplanationFor(delta.capabilityId);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: AiCard(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(delta.capabilityName,
                          style: AppTypographyTokens.cardTitle),
                      ),
                      Row(
                        children: [
                          Text('$displayOld',
                            style: AppTypographyTokens.bodyStrong.copyWith(
                              fontSize: 15,
                              color: AppColorTokens.textTertiary,
                            )),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s),
                            child: Icon(Icons.arrow_forward_rounded,
                              size: 14, color: AppColorTokens.textTertiary),
                          ),
                          Text('$displayNew',
                            style: AppTypographyTokens.bodyStrong.copyWith(
                              fontSize: 15,
                              color: isPositive
                                  ? AppColorTokens.success
                                  : isNegative
                                      ? AppColorTokens.danger
                                      : AppColorTokens.textPrimary,
                            )),
                          const SizedBox(width: AppSpacing.s),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? AppColorTokens.success.withAlpha(12)
                                  : isNegative
                                      ? AppColorTokens.danger.withAlpha(12)
                                      : AppColorTokens.surface,
                              borderRadius: AppRadius.radiusXs,
                            ),
                            child: Text(
                              displayDelta,
                              style: AppTypographyTokens.metadata.copyWith(
                                fontSize: 11,
                                color: isPositive
                                    ? AppColorTokens.success
                                    : isNegative
                                        ? AppColorTokens.danger
                                        : AppColorTokens.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    explanation,
                    style: AppTypographyTokens.body.copyWith(
                      fontSize: 14, height: 1.5,
                      color: AppColorTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
