// Pradigi OS — Capability Dashboard Page
//
// Professional analytics view of the user's 6-dimensional cognitive
// capability graph. Shows current scores, experiment-over-experiment
// deltas, confidence indicators, and recent activity log.
//
// Design: Stripe Dashboard / GitHub Insights / Linear Analytics.
// No radar chart. No RPG stats. No levels or tiers.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/academy_controller.dart';
import '../../logic/assessment_engine.dart';
import '../../data/experiment_001_config.dart';
import '../../../../../shared/theme/design_tokens.dart';
import '../../../../../shared/components/ai_card.dart';
import '../../../../../core/config/capability_config.dart';

class CapabilityDashboardPage extends StatelessWidget {
  const CapabilityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: Consumer<AcademyController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                _DashboardHeader(controller: controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...CapabilityRegistry.capabilities.map((cap) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.l,
                            ),
                            child: _CapabilityDetailRow(
                              capability: cap,
                              controller: controller,
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.l),
                        _RecentActivity(controller: controller),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final AcademyController controller;
  const _DashboardHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.m, AppSpacing.l, AppSpacing.m,
      ),
      decoration: const BoxDecoration(
        color: AppColorTokens.background,
        border: Border(bottom: BorderSide(color: AppColorTokens.divider)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              controller.returnToAcademy();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            borderRadius: AppRadius.radiusXs,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.arrow_back_rounded, size: 20,
                color: AppColorTokens.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Capability Dashboard',
              style: AppTypographyTokens.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Capability Detail Row ───────────────────────────────────

class _CapabilityDetailRow extends StatelessWidget {
  final CapabilityConfig capability;
  final AcademyController controller;

  const _CapabilityDetailRow({
    required this.capability,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final score = controller.scoreFor(capability.id);
    final delta = controller.deltaFor(capability.id);
    final displayScore = (score * 100).round();
    final displayDelta = delta > 0
        ? '+${(delta * 100).round()}'
        : '${(delta * 100).round()}';
    final hasChange = delta != 0;
    final isPositive = delta > 0;
    final isNegative = delta < 0;

    final result = controller.assessmentResult;
    final hasSignals =
        result?.deltaFor(capability.id)?.activatedSignals.isNotEmpty == true;

    final confidenceLevel = result?.deltaFor(capability.id)?.confidence ?? 0.0;
    final confidenceLabel = confidenceLevel >= 0.80
        ? 'High'
        : confidenceLevel >= 0.60 ? 'Medium' : 'Low';
    final confidenceColor = confidenceLevel >= 0.80
        ? AppColorTokens.success
        : confidenceLevel >= 0.60
            ? AppColorTokens.warning
            : AppColorTokens.textTertiary;

    return AiCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capability.name,
                      style: AppTypographyTokens.cardTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(capability.description,
                      style: AppTypographyTokens.caption.copyWith(
                        fontSize: 13, height: 1.4,
                      )),
                  ],
                ),
              ),
              if (!capability.isTestableInMVP)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.s),
                  child: Icon(Icons.lock_outline, size: 16,
                    color: AppColorTokens.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),

          // Score display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$displayScore',
                style: AppTypographyTokens.display.copyWith(
                  fontSize: 36,
                  color: AppColorTokens.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              if (hasChange)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    displayDelta,
                    style: AppTypographyTokens.bodyStrong.copyWith(
                      color: isPositive
                          ? AppColorTokens.success
                          : isNegative
                              ? AppColorTokens.danger
                              : AppColorTokens.textSecondary,
                    ),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Confidence',
                    style: AppTypographyTokens.metadata.copyWith(
                      fontSize: 11,
                    )),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withAlpha(12),
                      borderRadius: AppRadius.radiusXs,
                    ),
                    child: Text(confidenceLabel,
                      style: AppTypographyTokens.metadata.copyWith(
                        fontSize: 11, color: confidenceColor,
                      )),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),

          // Sparkline placeholder
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColorTokens.surface,
              borderRadius: AppRadius.radiusXs,
            ),
            child: Center(
              child: capability.isTestableInMVP
                  ? (hasSignals
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _sparklineSegment(12, true),
                            const SizedBox(width: 2),
                            _sparklineSegment(isPositive ? 24 : 14, true),
                          ],
                        )
                      : Text(
                          'Complete an experiment to build your trend',
                          style: AppTypographyTokens.metadata.copyWith(
                            fontSize: 11,
                          ),
                        ))
                  : Text(
                      'Coming soon',
                      style: AppTypographyTokens.metadata.copyWith(
                        fontSize: 11, color: AppColorTokens.textTertiary,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: AppSpacing.s),

          // Subtitle
          if (!capability.isTestableInMVP)
            Text(
              'Not yet evaluated in current experiments.',
              style: AppTypographyTokens.metadata.copyWith(
                fontSize: 11, color: AppColorTokens.textTertiary,
              ),
            )
          else if (!hasSignals)
            Text(
              'No signals activated in this experiment.',
              style: AppTypographyTokens.metadata.copyWith(
                fontSize: 11, color: AppColorTokens.textSecondary,
              ),
            )
          else
            Text(
              '↑ ${(delta * 100).round().abs()} this experiment',
              style: AppTypographyTokens.metadata.copyWith(
                fontSize: 11,
                color: isPositive
                    ? AppColorTokens.success
                    : AppColorTokens.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sparklineSegment(double height, bool active) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: active ? AppColorTokens.primary : AppColorTokens.divider,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

// ── Recent Activity ────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  final AcademyController controller;
  const _RecentActivity({required this.controller});

  @override
  Widget build(BuildContext context) {
    final result = controller.assessmentResult;
    final hasData = result != null &&
        result.deltas.any((d) => d.activatedSignals.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppTypographyTokens.sectionHeading),
        const SizedBox(height: AppSpacing.l),

        if (!hasData)
          AiCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Text(
                'Complete your first experiment to see activity here.',
                style: AppTypographyTokens.body.copyWith(
                  color: AppColorTokens.textSecondary,
                ),
              ),
            ),
          )
        else
          AiCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        color: AppColorTokens.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Experiment001.title,
                            style: AppTypographyTokens.bodyStrong.copyWith(
                              fontSize: 14,
                            )),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _formatActivitySummary(result),
                            style: AppTypographyTokens.caption.copyWith(
                              fontSize: 12, height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Today',
                            style: AppTypographyTokens.metadata.copyWith(
                              fontSize: 11,
                              color: AppColorTokens.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatActivitySummary(AssessmentResult result) {
    final parts = <String>[];
    for (final delta in result.deltas) {
      if (delta.activatedSignals.isNotEmpty) {
        final sign = delta.delta >= 0 ? '↑' : '↓';
        final amount = (delta.delta * 100).round().abs();
        parts.add('${delta.capabilityName} $sign$amount');
      }
    }
    return parts.join(', ');
  }
}
