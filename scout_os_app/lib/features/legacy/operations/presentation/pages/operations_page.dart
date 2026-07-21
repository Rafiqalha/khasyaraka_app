import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/operations/logic/operation_controller.dart';
import '../../../../core/domain/models/operation_model.dart';
import '../../../../core/domain/models/evidence_model.dart';
import '../../../../shared/theme/design_tokens.dart';
import '../../../../shared/components/ai_badge.dart';
import '../../../../shared/components/ai_card.dart';
import '../../../../shared/components/ai_loading_state.dart';
import '../../../../shared/components/ai_empty_state.dart';
import '../../../../shared/components/ai_button.dart';
import '../../../../shared/components/ai_section.dart';

/// Phase 5 — Operations Workspace
/// Thin-client renderer for AI-driven investigation state.
/// Tabs unlock progressively based on user's Capability level.
class OperationWorkspacePage extends StatefulWidget {
  final String missionId;
  final int userCapabilityLevel; // supplied from CapabilityController

  const OperationWorkspacePage({
    super.key,
    required this.missionId,
    this.userCapabilityLevel = 1,
  });

  @override
  State<OperationWorkspacePage> createState() => _OperationWorkspacePageState();
}

class _OperationWorkspacePageState extends State<OperationWorkspacePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount = _resolveTabCount(widget.userCapabilityLevel);
    _tabController = TabController(length: tabCount, vsync: this);

    // Start operation on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperationController>().startOperation(widget.missionId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Progressive disclosure: unlock tabs as capability grows
  int _resolveTabCount(int level) {
    if (level >= 5) return 5; // Evidence, Timeline, Logs, Packets, Terminal
    if (level >= 3) return 3; // Evidence, Timeline, Logs
    if (level >= 2) return 2; // Evidence, Timeline
    return 1;                  // Evidence only (Day 1)
  }

  List<Tab> _buildTabs(int level) {
    final allTabs = [
      const Tab(text: 'Evidence'),
      const Tab(text: 'Timeline'),
      const Tab(text: 'Logs'),
      const Tab(text: 'Packets'),
      const Tab(text: 'Terminal'),
    ];
    return allTabs.take(_resolveTabCount(level)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorTokens.background,
      appBar: AppBar(
        backgroundColor: AppColorTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operation Workspace', style: AppTypographyTokens.cardTitle),
            Text('Mission: ${widget.missionId}', style: AppTypographyTokens.metadata),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _buildTabs(widget.userCapabilityLevel),
          labelColor: AppColorTokens.primary,
          unselectedLabelColor: AppColorTokens.textSecondary,
          labelStyle: AppTypographyTokens.bodyStrong.copyWith(fontSize: 14),
          indicatorColor: AppColorTokens.primary,
          indicatorWeight: 2,
          dividerColor: AppColorTokens.divider,
        ),
      ),
      body: Consumer<OperationController>(
        builder: (context, controller, _) {
          // Show global loading while operation is being created
          if (controller.currentState == OperationState.generating) {
            return const AiLoadingState(message: 'Initializing secure workspace...');
          }

          if (controller.currentState == OperationState.failed) {
            return AiEmptyState(
              icon: Icons.signal_wifi_connected_no_internet_4_rounded,
              title: 'Workspace Offline',
              description: controller.errorMessage ?? 'Connection to AI Core lost.',
            );
          }

          if (controller.currentState == OperationState.evaluating) {
            return const AiLoadingState(message: 'AI Assessment Engine evaluating your operation...');
          }

          if (controller.currentState == OperationState.completed) {
            return const _OperationCompleteState();
          }

          // Operation is running — show workspace tabs
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _EvidenceTab(evidence: _getMockEvidence()),
                    _TimelineTab(),
                    if (widget.userCapabilityLevel >= 3) _LogsTab(),
                    if (widget.userCapabilityLevel >= 4) _PacketsTab(),
                    if (widget.userCapabilityLevel >= 5) _TerminalTab(),
                  ].take(_resolveTabCount(widget.userCapabilityLevel)).toList(),
                ),
              ),
              _WorkspaceActionBar(controller: controller),
            ],
          );
        },
      ),
    );
  }

  List<EvidenceModel> _getMockEvidence() => [
    EvidenceModel(
      id: 'evd_001',
      missionId: widget.missionId,
      type: 'log',
      content: '{"timestamp": "2026-07-18T10:00:00Z", "query": "evil-domain.com", "src_ip": "192.168.1.50"}',
      requiredCapabilityLevel: 1,
    ),
    EvidenceModel(
      id: 'evd_002',
      missionId: widget.missionId,
      type: 'timeline',
      content: 'User logged in at 09:55Z. DNS burst occurred at 10:00Z.',
      requiredCapabilityLevel: 1,
    ),
  ];
}

// ─────────────────────────────────────────────
// Tab: Evidence
// ─────────────────────────────────────────────
class _EvidenceTab extends StatelessWidget {
  final List<EvidenceModel> evidence;
  const _EvidenceTab({required this.evidence});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: evidence.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.l),
      itemBuilder: (context, index) {
        final e = evidence[index];
        return AiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AiBadge(label: e.type.toUpperCase(), status: AiBadgeStatus.info),
                  const Spacer(),
                  Text('Evidence ${index + 1}', style: AppTypographyTokens.metadata),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: AppRadius.radiusS,
                ),
                child: Text(
                  e.content,
                  style: AppTypographyTokens.terminalStyle.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Timeline
// ─────────────────────────────────────────────
class _TimelineTab extends StatelessWidget {
  final List<Map<String, String>> _events = const [
    {'time': '09:55 UTC', 'event': 'Internal user authenticated from 192.168.1.50', 'type': 'info'},
    {'time': '10:00 UTC', 'event': 'DNS burst: 47 queries to evil-domain.com', 'type': 'danger'},
    {'time': '10:02 UTC', 'event': 'Outbound connection attempt blocked by firewall', 'type': 'warning'},
    {'time': '10:05 UTC', 'event': 'Alert generated — SOC notified', 'type': 'success'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final e = _events[index];
        final status = e['type'] == 'danger'
            ? AiBadgeStatus.danger
            : e['type'] == 'warning'
                ? AiBadgeStatus.warning
                : e['type'] == 'success'
                    ? AiBadgeStatus.success
                    : AiBadgeStatus.info;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: status == AiBadgeStatus.danger
                          ? AppColorTokens.danger
                          : status == AiBadgeStatus.warning
                              ? AppColorTokens.warning
                              : AppColorTokens.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index < _events.length - 1)
                    Container(width: 2, height: 40, color: AppColorTokens.divider),
                ],
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['time']!, style: AppTypographyTokens.metadata),
                    const SizedBox(height: AppSpacing.xs),
                    Text(e['event']!, style: AppTypographyTokens.body),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Locked Tabs (Progressive Disclosure)
// ─────────────────────────────────────────────
class _LogsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _buildLockedTab('Logs', 'Investigation');
}

class _PacketsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _buildLockedTab('Packet Analysis', 'Deep Inspection');
}

class _TerminalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _buildLockedTab('Terminal', 'Command Line');
}

Widget _buildLockedTab(String title, String level) {
  return AiEmptyState(
    icon: Icons.lock_outline_rounded,
    title: '$title Locked',
    description: 'This capability unlocks at the $level competency level. Complete more operations to progress.',
  );
}

// ─────────────────────────────────────────────
// Bottom Action Bar
// ─────────────────────────────────────────────
class _WorkspaceActionBar extends StatelessWidget {
  final OperationController controller;
  const _WorkspaceActionBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.l, AppSpacing.xl, AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColorTokens.background,
        border: Border(top: BorderSide(color: AppColorTokens.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('AI Hypothesis', style: AppTypographyTokens.metadata.copyWith(color: AppColorTokens.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '"The DNS burst pattern indicates command-and-control beaconing from 192.168.1.50. Correlate with auth logs."',
            style: AppTypographyTokens.body.copyWith(color: AppColorTokens.textSecondary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.l),
          AiButton(
            label: 'Submit for AI Evaluation',
            icon: Icons.send_rounded,
            isFullWidth: true,
            onPressed: () {
              controller.submitForEvaluation({'hypothesis': 'C2 beaconing via DNS'});
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// State: Operation Complete
// ─────────────────────────────────────────────
class _OperationCompleteState extends StatelessWidget {
  const _OperationCompleteState();

  @override
  Widget build(BuildContext context) {
    return AiEmptyState(
      icon: Icons.verified_outlined,
      title: 'Operation Complete',
      description: 'AI Assessment Engine has processed your submission. Capability model is being updated.',
      action: AiButton(
        label: 'View Assessment',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
