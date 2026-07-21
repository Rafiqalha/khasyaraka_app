import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../features/mission/logic/mission_state_controller.dart';
import '../../../../core/domain/models/mission_model.dart';
import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/components/ai_badge.dart';
import '../../../../shared/components/ai_card.dart';
import '../../../../shared/components/ai_loading_state.dart';
import '../../../../shared/components/ai_empty_state.dart';
import '../../../../shared/components/ai_button.dart';

class MissionControlPage extends StatelessWidget {
  const MissionControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: Consumer<MissionStateController>(
          builder: (context, controller, _) {
            switch (controller.state) {
              case MissionEngineState.generating:
                return const _GeneratingState();
              case MissionEngineState.ready:
                return _MissionReadyState(mission: controller.currentMission!);
              case MissionEngineState.empty:
                return _EmptyMissionState(
                  onRefresh: controller.refreshMission,
                );
              case MissionEngineState.error:
                return _ErrorState(
                  message: controller.errorMessage ?? 'Unknown error.',
                  onRetry: controller.refreshMission,
                );
            }
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// State: AI Generating
// ─────────────────────────────────────────────
class _GeneratingState extends StatelessWidget {
  const _GeneratingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AiLoadingState(
        message: 'AI Core is analyzing global intelligence networks...',
      ),
    );
  }
}

// ─────────────────────────────────────────────
// State: Mission Ready
// ─────────────────────────────────────────────
class _MissionReadyState extends StatelessWidget {
  final MissionModel mission;
  const _MissionReadyState({required this.mission});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _MissionControlHeader(),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _IntelligenceBriefingCard(mission: mission),
              const SizedBox(height: AppSpacing.l),
              _MissionDetailCard(mission: mission),
              const SizedBox(height: AppSpacing.xl),
              AiButton(
                label: 'Deploy to Operation',
                icon: Icons.arrow_forward_rounded,
                isFullWidth: true,
                onPressed: () {
                  // Phase 5: Navigate to Workspace
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Header (SliverAppBar)
// ─────────────────────────────────────────────
class _MissionControlHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final date = DateFormat('EEEE, d MMM').format(now);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColorTokens.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColorTokens.background,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Intelligence Briefing',
                style: AppTypographyTokens.metadata.copyWith(
                  color: AppColorTokens.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(date, style: AppTypographyTokens.pageHeading),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card: Today's Intelligence Situation
// ─────────────────────────────────────────────
class _IntelligenceBriefingCard extends StatelessWidget {
  final MissionModel mission;
  const _IntelligenceBriefingCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColorTokens.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                'LIVE INTELLIGENCE',
                style: AppTypographyTokens.metadata.copyWith(
                  color: AppColorTokens.success,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'AI detected threats matching your lowest capability vector.',
            style: AppTypographyTokens.body,
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColorTokens.surface,
              borderRadius: AppRadius.radiusS,
              border: Border.all(color: AppColorTokens.divider),
            ),
            child: Text(
              '"Based on your recent ${mission.targetedCapability} performance, '
              'AI has generated an operation targeting your lowest skill gap: '
              '${mission.reason}"',
              style: AppTypographyTokens.body.copyWith(
                color: AppColorTokens.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card: Mission Details
// ─────────────────────────────────────────────
class _MissionDetailCard extends StatelessWidget {
  final MissionModel mission;
  const _MissionDetailCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Mission', style: AppTypographyTokens.metadata),
              AiBadge(
                label: 'Difficulty ${mission.difficulty}',
                status: mission.difficulty <= 2
                    ? AiBadgeStatus.success
                    : mission.difficulty <= 4
                        ? AiBadgeStatus.warning
                        : AiBadgeStatus.danger,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Operation: ${mission.targetedCapability} Investigation',
            style: AppTypographyTokens.cardTitle,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(mission.reason, style: AppTypographyTokens.body.copyWith(color: AppColorTokens.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: AppColorTokens.divider),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  label: 'Est. Success',
                  value: '${(mission.estimatedSuccess * 100).toStringAsFixed(0)}%',
                  icon: Icons.track_changes_outlined,
                  color: AppColorTokens.success,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  label: 'Generated',
                  value: DateFormat('HH:mm').format(mission.generatedAt),
                  icon: Icons.schedule_outlined,
                  color: AppColorTokens.textSecondary,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  label: 'Target',
                  value: mission.targetedCapability,
                  icon: Icons.auto_graph_outlined,
                  color: AppColorTokens.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypographyTokens.bodyStrong.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypographyTokens.metadata,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// State: Empty
// ─────────────────────────────────────────────
class _EmptyMissionState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyMissionState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AiEmptyState(
      icon: Icons.radar,
      title: 'No Active Briefing',
      description: 'AI Core is scanning global intelligence networks to prepare your next operation...',
      action: AiButton(
        label: 'Check Again',
        type: AiButtonType.outline,
        onPressed: onRefresh,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// State: Error
// ─────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AiEmptyState(
      icon: Icons.signal_wifi_connected_no_internet_4_rounded,
      title: 'Telemetry Lost',
      description: 'Re-establishing link with AI Core. Error: $message',
      action: AiButton(
        label: 'Reconnect',
        onPressed: onRetry,
      ),
    );
  }
}
