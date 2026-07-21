import 'package:flutter/material.dart';
import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/components/ai_card.dart';
import '../../../../shared/components/ai_badge.dart';
import '../../../../shared/components/ai_section.dart';
import '../../../../shared/components/ai_button.dart';
import '../../../../shared/components/ai_empty_state.dart';
import '../../../../core/domain/models/patrol_model.dart';

/// Phase 7 — Community Intelligence
/// Patrol recommendations, AI team matching, and social capability aggregation.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _CommunityHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _PatrolMatchCard(),
                  const SizedBox(height: AppSpacing.l),
                  AiSection(
                    title: 'Nearby Scouts',
                    description: 'AI detected complementary skill gaps',
                    child: _NearbyScoutsList(),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AiSection(
                    title: 'Your Patrol',
                    description: 'Aggregate capability of Regu Rajawali',
                    child: _PatrolCapabilityCard(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _CommunityHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColorTokens.background,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PATROL INTELLIGENCE',
              style: AppTypographyTokens.metadata.copyWith(
                color: AppColorTokens.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Community Orchestration', style: AppTypographyTokens.pageHeading),
            const SizedBox(height: AppSpacing.s),
            Text(
              'AI is continuously matching scouts based on complementary capabilities.',
              style: AppTypographyTokens.caption,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Patrol Match CTA
// ─────────────────────────────────────────────
class _PatrolMatchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColorTokens.primaryLight,
                  borderRadius: AppRadius.radiusS,
                ),
                child: const Icon(Icons.groups_rounded, color: AppColorTokens.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Patrol Suggested', style: AppTypographyTokens.cardTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text('AI found 3 scouts with complementary skills', style: AppTypographyTokens.caption),
                  ],
                ),
              ),
              AiBadge(label: 'New', status: AiBadgeStatus.info, icon: Icons.auto_awesome),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColorTokens.surface,
              borderRadius: AppRadius.radiusS,
              border: Border.all(color: AppColorTokens.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.smart_toy_outlined, size: 16, color: AppColorTokens.primary),
                    const SizedBox(width: AppSpacing.s),
                    Text('AI Recommendation', style: AppTypographyTokens.metadata.copyWith(color: AppColorTokens.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  '"Regu Rajawali kekurangan keahlian Incident Response. '
                  'Adi (Communication: 92) dan Budi (Detection: 88) direkomendasikan '
                  'untuk menyeimbangkan kapabilitas regu."',
                  style: AppTypographyTokens.body.copyWith(
                    color: AppColorTokens.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: AiButton(
                  label: 'Accept Formation',
                  isFullWidth: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: AiButton(
                  label: 'Decline',
                  type: AiButtonType.outline,
                  isFullWidth: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nearby Scouts List
// ─────────────────────────────────────────────
class _NearbyScoutsList extends StatelessWidget {
  // Static mock data representing AI-matched scouts
  final List<Map<String, dynamic>> _scouts = const [
    {
      'name': 'Adi Pratama',
      'unit': 'SDN 04 Jakarta',
      'dominant': 'Communication',
      'score': 92.0,
      'match': 'High Match',
      'status': AiBadgeStatus.success,
    },
    {
      'name': 'Budi Santoso',
      'unit': 'SMPN 7 Depok',
      'dominant': 'Detection',
      'score': 88.0,
      'match': 'High Match',
      'status': AiBadgeStatus.success,
    },
    {
      'name': 'Citra Dewi',
      'unit': 'SMAN 3 Bekasi',
      'dominant': 'Leadership',
      'score': 75.0,
      'match': 'Good Match',
      'status': AiBadgeStatus.info,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _scouts.map((scout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: AiCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            onTap: () {},
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColorTokens.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (scout['name'] as String).substring(0, 1),
                      style: AppTypographyTokens.cardTitle.copyWith(color: AppColorTokens.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scout['name'] as String, style: AppTypographyTokens.bodyStrong),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${scout['unit']} · ${scout['dominant']}: ${(scout['score'] as double).toStringAsFixed(0)}',
                        style: AppTypographyTokens.caption,
                      ),
                    ],
                  ),
                ),
                AiBadge(
                  label: scout['match'] as String,
                  status: scout['status'] as AiBadgeStatus,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Patrol Aggregate Capability Card
// ─────────────────────────────────────────────
class _PatrolCapabilityCard extends StatelessWidget {
  final List<Map<String, dynamic>> _vectors = const [
    {'label': 'Detection', 'patrol': 65.0, 'gap': false},
    {'label': 'Investigation', 'patrol': 72.0, 'gap': false},
    {'label': 'Reasoning', 'patrol': 80.0, 'gap': false},
    {'label': 'Communication', 'patrol': 38.0, 'gap': true},
    {'label': 'Automation', 'patrol': 25.0, 'gap': true},
    {'label': 'Leadership', 'patrol': 70.0, 'gap': false},
  ];

  @override
  Widget build(BuildContext context) {
    return AiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Regu Rajawali', style: AppTypographyTokens.cardTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text('5 members · Kwarcab Jakarta Selatan', style: AppTypographyTokens.caption),
                  ],
                ),
              ),
              AiBadge(label: 'Active', status: AiBadgeStatus.success, icon: Icons.circle),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          const Divider(color: AppColorTokens.divider),
          const SizedBox(height: AppSpacing.l),
          ..._vectors.map((v) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      v['label'] as String,
                      style: AppTypographyTokens.caption.copyWith(
                        color: v['gap'] == true ? AppColorTokens.danger : AppColorTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusXs,
                      child: LinearProgressIndicator(
                        value: (v['patrol'] as double) / 100.0,
                        backgroundColor: AppColorTokens.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          v['gap'] == true ? AppColorTokens.warning : AppColorTokens.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(v['patrol'] as double).toStringAsFixed(0)}',
                      style: AppTypographyTokens.caption.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (v['gap'] == true)
                    const Padding(
                      padding: EdgeInsets.only(left: AppSpacing.s),
                      child: Icon(Icons.warning_amber_rounded, size: 14, color: AppColorTokens.warning),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.s),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColorTokens.warning.withValues(alpha: 0.08),
              borderRadius: AppRadius.radiusS,
              border: Border.all(color: AppColorTokens.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_outlined, size: 16, color: AppColorTokens.warning),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    '"Communication and Automation are critical gaps. '
                    'AI recommends 2 specialized recruits to strengthen Regu Rajawali."',
                    style: AppTypographyTokens.caption.copyWith(color: AppColorTokens.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
