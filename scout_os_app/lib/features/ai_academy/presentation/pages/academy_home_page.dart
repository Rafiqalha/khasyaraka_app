// Pradigi OS — AI Academy Home Page
//
// The root screen of the AI Academy. This is the permanent home users
// return to after every experiment. It shows today's experiment and
// current capability snapshot.
//
// Design: Linear / Notion / Apple Notes — minimal, white, thinking-first.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../logic/academy_controller.dart';
import '../../data/experiment_001_config.dart';
import '../../../../../shared/theme/design_tokens.dart';
import '../../../../../shared/components/ai_card.dart';
import '../../../../../shared/components/ai_button.dart';
import '../../../../../shared/components/ai_badge.dart';
import '../../../../../core/config/capability_config.dart';

class AcademyHomePage extends StatelessWidget {
  const AcademyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: Consumer<AcademyController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GreetingHeader(),
                        const SizedBox(height: AppSpacing.xxl),
                        _ExperimentCard(controller: controller),
                        const SizedBox(height: AppSpacing.xl),
                        _CapabilitySnapshot(controller: controller),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                // Bottom is intentionally empty — no tab bar, no footer.
                // Academy Home is the root. Clean exit point.
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Greeting Header ───────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting =
        now.hour < 12 ? 'Good morning' : now.hour < 17 ? 'Good afternoon' : 'Good evening';
    final date = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Academy',
            style: AppTypographyTokens.metadata.copyWith(
              color: AppColorTokens.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(greeting, style: AppTypographyTokens.pageHeading),
          const SizedBox(height: AppSpacing.xs),
          Text(date, style: AppTypographyTokens.caption),
        ],
      ),
    );
  }
}

// ── Experiment Card ───────────────────────────────────────────

class _ExperimentCard extends StatelessWidget {
  final AcademyController controller;

  const _ExperimentCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Experiment', style: AppTypographyTokens.metadata),
              AiBadge(
                label: '~${Experiment001.estimatedMinutes} min',
                status: AiBadgeStatus.info,
                icon: Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(Experiment001.title, style: AppTypographyTokens.cardTitle),
          const SizedBox(height: AppSpacing.s),
          Text(
            Experiment001.description,
            style: AppTypographyTokens.body.copyWith(
              color: AppColorTokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _CapabilityChip('AI Communication'),
              _CapabilityChip('AI Reasoning'),
              _CapabilityChip('AI Safety'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AiButton(
            label: 'Begin Experiment',
            icon: Icons.arrow_forward_rounded,
            isFullWidth: true,
            onPressed: () => controller.beginExperiment(),
          ),
        ],
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  final String label;
  const _CapabilityChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m, vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColorTokens.primaryLight,
        borderRadius: AppRadius.radiusXs,
      ),
      child: Text(
        label,
        style: AppTypographyTokens.metadata.copyWith(
          color: AppColorTokens.primaryDark,
        ),
      ),
    );
  }
}

// ── Capability Snapshot ────────────────────────────────────────

class _CapabilitySnapshot extends StatelessWidget {
  final AcademyController controller;

  const _CapabilitySnapshot({required this.controller});

  @override
  Widget build(BuildContext context) {
    final caps = CapabilityRegistry.capabilities;
    final totalCompleted = controller.findings.isNotEmpty ? 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Capability', style: AppTypographyTokens.sectionHeading),
            if (totalCompleted > 0)
              AiButton(
                label: 'View Details',
                type: AiButtonType.text,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => controller.viewDashboard(),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          '$totalCompleted experiment${totalCompleted != 1 ? 's' : ''} completed.',
          style: AppTypographyTokens.caption,
        ),
        const SizedBox(height: AppSpacing.l),
        AiCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              for (int i = 0; i < caps.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                    child: Divider(color: AppColorTokens.divider, height: 1),
                  ),
                _CapabilityRow(
                  name: caps[i].name,
                  score: controller.scoreFor(caps[i].id),
                  isTestable: caps[i].isTestableInMVP,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  final String name;
  final double score;
  final bool isTestable;

  const _CapabilityRow({
    required this.name,
    required this.score,
    required this.isTestable,
  });

  @override
  Widget build(BuildContext context) {
    final displayScore = (score * 100).round();
    final pct = score.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypographyTokens.bodyStrong.copyWith(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '$displayScore',
                      style: AppTypographyTokens.bodyStrong.copyWith(
                        fontSize: 15,
                        color: AppColorTokens.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadius.radiusXs,
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: AppColorTokens.divider,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColorTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isTestable) ...[
            const SizedBox(width: AppSpacing.s),
            Icon(Icons.lock_outline, size: 14, color: AppColorTokens.textTertiary),
          ],
        ],
      ),
    );
  }
}
