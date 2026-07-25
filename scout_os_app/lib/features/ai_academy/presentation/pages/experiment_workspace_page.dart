// Pradigi OS — Experiment Workspace Page
//
// The core product surface. Users spend 95% of their time here.
// Three phases: Prompt → Verify → Defend.
//
// Design: Linear / Notion / Perplexity — split-pane thinking environment.
// AI is silent during the experiment. No popups. No gamification.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/academy_controller.dart';
import '../../data/experiment_001_config.dart';
import '../../../../../shared/theme/design_tokens.dart';
import '../../../../../shared/components/ai_card.dart';
import '../../../../../shared/components/ai_button.dart';

class ExperimentWorkspacePage extends StatefulWidget {
  const ExperimentWorkspacePage({super.key});

  @override
  State<ExperimentWorkspacePage> createState() =>
      _ExperimentWorkspacePageState();
}

class _ExperimentWorkspacePageState extends State<ExperimentWorkspacePage> {
  final _promptController = TextEditingController();
  final _findingDescController = TextEditingController();
  final _findingSourceController = TextEditingController();
  final _findingExplainController = TextEditingController();
  final _injectionExplainController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    _findingDescController.dispose();
    _findingSourceController.dispose();
    _findingExplainController.dispose();
    _injectionExplainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AcademyController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: AppColorTokens.surface,
          body: SafeArea(
            child: Column(
              children: [
                _WorkspaceHeader(controller: controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _phaseContent(controller),
                  ),
                ),
                _PhaseActions(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _phaseContent(AcademyController controller) {
    switch (controller.currentPhase) {
      case ExperimentPhase.phase1Prompt:
        return _Phase1Prompt(controller: controller);
      case ExperimentPhase.phase2Verify:
        return _Phase2Verify(controller: controller);
      case ExperimentPhase.phase3Defend:
        return _Phase3Defend(controller: controller);
    }
  }
}

// ── Header ────────────────────────────────────────────────────

class _WorkspaceHeader extends StatelessWidget {
  final AcademyController controller;
  const _WorkspaceHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final phases = Experiment001.phases;
    final phaseIndex = controller.currentPhase.index;
    final currentPhaseData = phases[phaseIndex];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.s,
      ),
      decoration: const BoxDecoration(
        color: AppColorTokens.background,
        border: Border(bottom: BorderSide(color: AppColorTokens.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
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
                  Experiment001.title,
                  style: AppTypographyTokens.bodyStrong,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${phaseIndex + 1}/${phases.length}',
                style: AppTypographyTokens.metadata.copyWith(
                  color: AppColorTokens.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (int i = 0; i < phases.length; i++) ...[
                if (i > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= phaseIndex
                          ? AppColorTokens.primary
                          : AppColorTokens.divider,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= phaseIndex
                        ? AppColorTokens.primary
                        : AppColorTokens.divider,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            currentPhaseData['title'] as String,
            style: AppTypographyTokens.metadata.copyWith(
              color: AppColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Phase 1: Prompt the AI ────────────────────────────────────

class _Phase1Prompt extends StatelessWidget {
  final AcademyController controller;
  const _Phase1Prompt({required this.controller});

  @override
  Widget build(BuildContext context) {
    final instruction =
        (Experiment001.phases[0]['instruction'] as String?) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            instruction,
            style: AppTypographyTokens.body.copyWith(
              color: AppColorTokens.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        if (!controller.promptSubmitted) ...[
          Text('Your Prompt', style: AppTypographyTokens.cardTitle),
          const SizedBox(height: AppSpacing.m),
          _PromptTextField(),
        ] else ...[
          Text('Your Prompt', style: AppTypographyTokens.metadata),
          const SizedBox(height: AppSpacing.s),
          AiCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              controller.promptText,
              style: AppTypographyTokens.body.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('AI-Generated Report', style: AppTypographyTokens.cardTitle),
          const SizedBox(height: AppSpacing.m),
          AiCard(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              Experiment001.generatedReport,
              style: AppTypographyTokens.body.copyWith(
                fontSize: 14,
                height: 1.7,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PromptTextField extends StatefulWidget {
  @override
  State<_PromptTextField> createState() => _PromptTextFieldState();
}

class _PromptTextFieldState extends State<_PromptTextField> {
  final _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academy = context.read<AcademyController>();

    return AiCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLines: 6,
            enabled: !_submitted,
            style: AppTypographyTokens.body.copyWith(height: 1.6),
            decoration: const InputDecoration(
              hintText: 'Write a prompt that instructs the AI to '
                  'generate an accurate market report...',
              hintStyle: TextStyle(color: AppColorTokens.textTertiary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_submitted)
                AiButton(
                  label: 'Revise',
                  type: AiButtonType.outline,
                  onPressed: () {
                    setState(() => _submitted = false);
                  },
                ),
              if (_submitted) const SizedBox(width: AppSpacing.s),
              AiButton(
                label: _submitted ? 'Generate Again' : 'Generate Report',
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  if (_submitted) {
                    academy.revisePrompt(_controller.text.trim());
                  } else {
                    academy.submitPrompt(_controller.text.trim());
                    setState(() => _submitted = true);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Phase 2: Verify the Output ────────────────────────────────

class _Phase2Verify extends StatefulWidget {
  final AcademyController controller;
  const _Phase2Verify({required this.controller});

  @override
  State<_Phase2Verify> createState() => _Phase2VerifyState();
}

class _Phase2VerifyState extends State<_Phase2Verify> {
  final _descCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  final _explainCtrl = TextEditingController();

  @override
  void dispose() {
    _descCtrl.dispose();
    _sourceCtrl.dispose();
    _explainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final instruction =
        (Experiment001.phases[1]['instruction'] as String?) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            instruction,
            style: AppTypographyTokens.body.copyWith(
              color: AppColorTokens.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text('Generated Report', style: AppTypographyTokens.cardTitle),
        const SizedBox(height: AppSpacing.m),
        AiCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            Experiment001.generatedReport,
            style: AppTypographyTokens.body.copyWith(
              fontSize: 14, height: 1.7, fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text('Verified Sources', style: AppTypographyTokens.cardTitle),
        const SizedBox(height: AppSpacing.m),
        ...Experiment001.sources.map((source) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: AiCard(
              padding: const EdgeInsets.all(AppSpacing.l),
              onTap: () {
                ctrl.openSource();
                _showSourceDetail(context, source);
              },
              isInteractive: true,
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                    size: 18, color: AppColorTokens.primary),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      source['title'] as String,
                      style: AppTypographyTokens.bodyStrong.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColorTokens.textTertiary),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xl),

        Text('Your Findings', style: AppTypographyTokens.cardTitle),
        const SizedBox(height: AppSpacing.s),
        Text(
          '${ctrl.findings.where((f) => f.isCorrect).length} verified, '
          '${ctrl.findings.where((f) => f.isFalsePositive).length} to review',
          style: AppTypographyTokens.caption,
        ),
        const SizedBox(height: AppSpacing.m),

        if (ctrl.findings.isNotEmpty)
          ...ctrl.findings.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: AiCard(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                children: [
                  Icon(
                    f.isCorrect
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    size: 18,
                    color: f.isCorrect
                        ? AppColorTokens.success
                        : AppColorTokens.warning,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      f.description,
                      style: AppTypographyTokens.body.copyWith(fontSize: 14),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )),

        const SizedBox(height: AppSpacing.m),
        AiButton(
          label: '+ Add Finding',
          type: AiButtonType.outline,
          isFullWidth: true,
          icon: Icons.add,
          onPressed: () => _showAddFindingDialog(context, ctrl),
        ),
      ],
    );
  }

  void _showSourceDetail(
      BuildContext ctx, Map<String, dynamic> source) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColorTokens.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(source['title'] as String,
                style: AppTypographyTokens.cardTitle),
              const SizedBox(height: AppSpacing.s),
              Text('Verified by: ${source['verifiedBy']}',
                style: AppTypographyTokens.metadata),
              const Divider(height: AppSpacing.xxl,
                color: AppColorTokens.divider),
              Text(source['content'] as String,
                style: AppTypographyTokens.body.copyWith(
                  height: 1.7, fontSize: 15,
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFindingDialog(
      BuildContext ctx, AcademyController ctrl) {
    _descCtrl.clear();
    _sourceCtrl.clear();
    _explainCtrl.clear();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColorTokens.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('New Finding', style: AppTypographyTokens.cardTitle),
              const SizedBox(height: AppSpacing.l),

              Text('What did you find?',
                style: AppTypographyTokens.bodyStrong),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                style: AppTypographyTokens.body.copyWith(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Describe the error you found...',
                  hintStyle: TextStyle(color: AppColorTokens.textTertiary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorTokens.divider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              Text('Which source confirms this?',
                style: AppTypographyTokens.bodyStrong),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _sourceCtrl,
                style: AppTypographyTokens.body.copyWith(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'e.g., BPS Export Statistics Q1 2025',
                  hintStyle: TextStyle(color: AppColorTokens.textTertiary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorTokens.divider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              Text('Explain the discrepancy',
                style: AppTypographyTokens.bodyStrong),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _explainCtrl,
                maxLines: 4,
                style: AppTypographyTokens.body.copyWith(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'What did the AI get wrong and why?',
                  hintStyle: TextStyle(color: AppColorTokens.textTertiary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColorTokens.divider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              AiButton(
                label: 'Submit Finding',
                isFullWidth: true,
                onPressed: () {
                  final desc = _descCtrl.text.trim();
                  if (desc.isEmpty) return;
                  ctrl.addFinding(
                    hallucinationId: 'manual_${ctrl.findings.length}',
                    description: desc,
                    sourceId: _sourceCtrl.text.trim(),
                    explanation: _explainCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Phase 3: Defend the System ───────────────────────────────

class _Phase3Defend extends StatefulWidget {
  final AcademyController controller;
  const _Phase3Defend({required this.controller});

  @override
  State<_Phase3Defend> createState() => _Phase3DefendState();
}

class _Phase3DefendState extends State<_Phase3Defend> {
  String? _selectedInjectionId;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final instruction =
        (Experiment001.phases[2]['instruction'] as String?) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiCard(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            instruction,
            style: AppTypographyTokens.body.copyWith(
              color: AppColorTokens.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        if (_selectedInjectionId == null)
          ...Experiment001.injectionScenarios.map((scenario) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: AiCard(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scenario['title'] as String,
                      style: AppTypographyTokens.cardTitle),
                    const SizedBox(height: AppSpacing.m),
                    Text(scenario['content'] as String,
                      style: AppTypographyTokens.body.copyWith(
                        fontSize: 14, height: 1.6, fontFamily: 'monospace',
                      )),
                    const SizedBox(height: AppSpacing.m),
                    Text('This input is an attempt to:',
                      style: AppTypographyTokens.bodyStrong),
                    ..._buildOptions(scenario, ctrl),
                    const SizedBox(height: AppSpacing.m),

                    if (ctrl.injectionResponse != null &&
                        ctrl.injectionResponse!.injectionId ==
                            scenario['id'])
                      _buildInjectionFeedback(ctrl),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  List<Widget> _buildOptions(
      Map<String, dynamic> scenario, AcademyController ctrl) {
    final options = scenario['options'] as List;
    final alreadyResponded = ctrl.injectionResponse != null &&
        ctrl.injectionResponse!.injectionId == scenario['id'];

    return options.map<Widget>((opt) {
      final isSelected = ctrl.injectionResponse?.selectedOptionId == opt['id'];
      final isCorrect = opt['isCorrect'] == true;

      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s),
        child: InkWell(
          onTap: alreadyResponded ? null : () => _showExplainDialog(
            scenario['id'] as String, opt['id'] as String, ctrl),
          borderRadius: AppRadius.radiusXs,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: alreadyResponded
                  ? (isSelected
                      ? (isCorrect
                          ? AppColorTokens.success.withAlpha(12)
                          : AppColorTokens.danger.withAlpha(12))
                      : AppColorTokens.surface)
                  : AppColorTokens.surface,
              borderRadius: AppRadius.radiusXs,
              border: Border.all(
                color: alreadyResponded && isSelected
                    ? (isCorrect
                        ? AppColorTokens.success
                        : AppColorTokens.danger)
                    : AppColorTokens.divider,
              ),
            ),
            child: Row(
              children: [
                if (alreadyResponded && isSelected)
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: isCorrect
                        ? AppColorTokens.success
                        : AppColorTokens.danger,
                  )
                else
                  Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColorTokens.divider),
                    ),
                  ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(
                    opt['label'] as String,
                    style: AppTypographyTokens.body.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildInjectionFeedback(AcademyController ctrl) {
    final resp = ctrl.injectionResponse!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: resp.isCorrect
            ? AppColorTokens.success.withAlpha(8)
            : AppColorTokens.danger.withAlpha(8),
        borderRadius: AppRadius.radiusXs,
        border: Border.all(
          color: resp.isCorrect
              ? AppColorTokens.success.withAlpha(40)
              : AppColorTokens.danger.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resp.isCorrect
                ? 'Correct — this was a prompt injection attack.'
                : 'Incorrect — review the scenario and try again.',
            style: AppTypographyTokens.bodyStrong.copyWith(
              fontSize: 14,
              color: resp.isCorrect
                  ? AppColorTokens.success
                  : AppColorTokens.danger,
            ),
          ),
          if (resp.explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(resp.explanation,
              style: AppTypographyTokens.body.copyWith(
                fontSize: 13,
                color: AppColorTokens.textSecondary,
              )),
          ],
        ],
      ),
    );
  }

  void _showExplainDialog(
      String injectionId, String optionId, AcademyController ctrl) {
    final explainCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColorTokens.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Explain your reasoning',
              style: AppTypographyTokens.cardTitle),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: explainCtrl,
              maxLines: 4,
              style: AppTypographyTokens.body.copyWith(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Why is this an attack? What should happen to this input?',
                hintStyle: TextStyle(color: AppColorTokens.textTertiary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColorTokens.divider),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AiButton(
              label: 'Submit Response',
              isFullWidth: true,
              onPressed: () {
                ctrl.submitInjectionResponse(
                  injectionId: injectionId,
                  selectedOptionId: optionId,
                  explanation: explainCtrl.text.trim(),
                );
                setState(() => _selectedInjectionId = injectionId);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}

// ── Phase Navigation Actions ─────────────────────────────────

class _PhaseActions extends StatelessWidget {
  final AcademyController controller;
  const _PhaseActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColorTokens.background,
        border: Border(top: BorderSide(color: AppColorTokens.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (controller.currentPhase != ExperimentPhase.phase1Prompt)
              Expanded(
                child: AiButton(
                  label: 'Previous',
                  type: AiButtonType.outline,
                  isFullWidth: true,
                  onPressed: () {
                    // For MVP, phase navigation is linear forward only
                    // "Previous" returns to academy
                    Navigator.pop(context);
                  },
                ),
              ),
            if (controller.currentPhase != ExperimentPhase.phase1Prompt)
              const SizedBox(width: AppSpacing.m),

            Expanded(
              child: AiButton(
                label: _actionLabel,
                isFullWidth: true,
                onPressed: () => _onAction(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _actionLabel {
    switch (controller.currentPhase) {
      case ExperimentPhase.phase1Prompt:
        return controller.promptSubmitted
            ? 'Next: Verify the Output'
            : 'Submit Prompt';
      case ExperimentPhase.phase2Verify:
        return 'Next: Defend the System';
      case ExperimentPhase.phase3Defend:
        return 'Submit All Findings';
    }
  }

  void _onAction(BuildContext context) {
    final ctrl = controller;

    switch (ctrl.currentPhase) {
      case ExperimentPhase.phase1Prompt:
        if (!ctrl.promptSubmitted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            ctrl.advancePhase();
            return const ExperimentWorkspacePage();
          }),
        );
      case ExperimentPhase.phase2Verify:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            ctrl.advancePhase();
            return const ExperimentWorkspacePage();
          }),
        );
      case ExperimentPhase.phase3Defend:
        ctrl.submitAllFindings();
        Navigator.pushNamed(context, '/mission-summary');
    }
  }
}
