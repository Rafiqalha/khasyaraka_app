import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/capability/logic/capability_controller.dart';
import '../../../../core/domain/models/capability_model.dart';
import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/components/ai_card.dart';
import '../../../../shared/components/ai_badge.dart';
import '../../../../shared/components/ai_loading_state.dart';
import '../../../../shared/components/ai_section.dart';
import '../widgets/capability_radar_chart.dart';

class CapabilityPage extends StatelessWidget {
  const CapabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: Consumer<CapabilityController>(
          builder: (context, controller, _) {
            if (controller.state == CapabilityEngineState.syncing) {
              return const AiLoadingState(message: 'Syncing telemetry from Assessment Engine...');
            }
            if (controller.state == CapabilityEngineState.error || controller.currentCapability == null) {
              return const Center(child: Text('Failed to sync capability data.'));
            }
            return _CapabilityDossier(capability: controller.currentCapability!);
          },
        ),
      ),
    );
  }
}

class _CapabilityDossier extends StatelessWidget {
  final CapabilityModel capability;
  const _CapabilityDossier({required this.capability});

  Map<String, double> get _capabilityMap => {
    'Detection': capability.detection,
    'Investig.': capability.investigation,
    'Reasoning': capability.reasoning,
    'Comms': capability.communication,
    'Automation': capability.automation,
    'Leadership': capability.leadership,
  };

  double get _overallScore {
    final vals = [
      capability.detection, capability.investigation, capability.reasoning,
      capability.communication, capability.automation, capability.leadership,
    ];
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: AppColorTokens.background,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAPABILITY MATRIX',
                  style: AppTypographyTokens.metadata.copyWith(
                    color: AppColorTokens.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Skill Vector Analysis', style: AppTypographyTokens.pageHeading),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Updated by AI Assessment Engine · Live',
                  style: AppTypographyTokens.caption,
                ),
              ],
            ),
          ),
        ),

        // ── Radar Chart ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: AppColorTokens.background,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                SizedBox(
                  height: 280,
                  child: CapabilityRadarChart(capabilities: _capabilityMap),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Overall Score
                _OverallScoreRow(score: _overallScore),
              ],
            ),
          ),
        ),

        // ── Individual Vectors ────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AiSection(
                title: 'Skill Vectors',
                description: 'AI-generated from operation history',
                child: Column(
                  children: [
                    _CapabilityVectorRow(
                      label: 'Detection',
                      value: capability.detection,
                      delta: '+4.5',
                      explanation: 'Increased: You correctly identified 3/3 indicators in the last DNS operation.',
                      icon: Icons.radar_outlined,
                    ),
                    _CapabilityVectorRow(
                      label: 'Investigation',
                      value: capability.investigation,
                      delta: '+1.2',
                      explanation: 'Slight increase: Good evidence correlation, but timeline reconstruction was slow.',
                      icon: Icons.manage_search_outlined,
                    ),
                    _CapabilityVectorRow(
                      label: 'Reasoning',
                      value: capability.reasoning,
                      delta: '+0.0',
                      explanation: 'Stable: No operations that directly tested logical deduction this week.',
                      icon: Icons.psychology_outlined,
                    ),
                    _CapabilityVectorRow(
                      label: 'Communication',
                      value: capability.communication,
                      delta: '-1.0',
                      explanation: 'Decreased: Incident report submitted without executive summary. Always include one.',
                      icon: Icons.broadcast_on_personal_outlined,
                      isDrop: true,
                    ),
                    _CapabilityVectorRow(
                      label: 'Automation',
                      value: capability.automation,
                      delta: '+0.0',
                      explanation: 'Terminal access not yet unlocked. Complete 60 days to enable.',
                      icon: Icons.terminal_outlined,
                    ),
                    _CapabilityVectorRow(
                      label: 'Leadership',
                      value: capability.leadership,
                      delta: '+2.0',
                      explanation: 'Increased: You were assigned and completed a Patrol Leader role successfully.',
                      icon: Icons.groups_outlined,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Overall Score Pill
// ─────────────────────────────────────────────
class _OverallScoreRow extends StatelessWidget {
  final double score;
  const _OverallScoreRow({required this.score});

  String get _ratingLabel {
    if (score >= 80) return 'Expert';
    if (score >= 60) return 'Advanced';
    if (score >= 40) return 'Competent';
    if (score >= 20) return 'Developing';
    return 'Novice';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              score.toStringAsFixed(1),
              style: AppTypographyTokens.display.copyWith(
                color: AppColorTokens.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text('Overall Score', style: AppTypographyTokens.caption),
          ],
        ),
        const SizedBox(width: AppSpacing.xl),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AiBadge(label: _ratingLabel, status: AiBadgeStatus.info),
            const SizedBox(height: AppSpacing.xs),
            Text('Capability Level', style: AppTypographyTokens.caption),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Individual Capability Row with AI Explanation
// ─────────────────────────────────────────────
class _CapabilityVectorRow extends StatefulWidget {
  final String label;
  final double value;
  final String delta;
  final String explanation;
  final IconData icon;
  final bool isDrop;

  const _CapabilityVectorRow({
    required this.label,
    required this.value,
    required this.delta,
    required this.explanation,
    required this.icon,
    this.isDrop = false,
  });

  @override
  State<_CapabilityVectorRow> createState() => _CapabilityVectorRowState();
}

class _CapabilityVectorRowState extends State<_CapabilityVectorRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final deltaColor = widget.isDrop ? AppColorTokens.danger : AppColorTokens.success;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: AiCard(
        padding: const EdgeInsets.all(AppSpacing.l),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 20, color: AppColorTokens.primary),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(widget.label, style: AppTypographyTokens.bodyStrong),
                ),
                Text(
                  widget.delta,
                  style: AppTypographyTokens.bodyStrong.copyWith(color: deltaColor),
                ),
                const SizedBox(width: AppSpacing.m),
                Text(
                  widget.value.toStringAsFixed(1),
                  style: AppTypographyTokens.cardTitle.copyWith(color: AppColorTokens.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.radiusXs,
              child: LinearProgressIndicator(
                value: widget.value / 100.0,
                backgroundColor: AppColorTokens.surface,
                valueColor: AlwaysStoppedAnimation<Color>(AppColorTokens.primary),
                minHeight: 6,
              ),
            ),
            // AI Explanation (expandable)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.l),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColorTokens.primaryLight,
                    borderRadius: AppRadius.radiusS,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.smart_toy_outlined, size: 16, color: AppColorTokens.primary),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          widget.explanation,
                          style: AppTypographyTokens.caption.copyWith(color: AppColorTokens.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
