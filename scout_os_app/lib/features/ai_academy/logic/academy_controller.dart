// Pradigi OS — Academy Controller
//
// Central state machine for the AI Academy experiment flow.
// Manages: flow state, phase tracking, telemetry collection,
// answer verification, assessment execution, and capability scores.
//
// This is a ChangeNotifier — the UI binds to it via Provider/Consumer.

import 'package:flutter/foundation.dart';
import 'assessment_engine.dart';
import '../data/experiment_001_config.dart';
import '../../../core/config/capability_config.dart';

// ── Flow State Enum ────────────────────────────────────────

enum AcademyFlowState {
  academyHome,        // Showing the AI Academy home page
  experimentActive,   // User is in the workspace (any phase)
  experimentComplete, // User submitted all findings, awaiting assessment
  summaryReady,       // Assessment done, showing mission summary
  dashboardReady,     // Showing capability dashboard
}

// ── Experiment Phase Enum ──────────────────────────────────

enum ExperimentPhase {
  phase1Prompt,       // Phase 1: Write a prompt
  phase2Verify,       // Phase 2: Detect hallucinations
  phase3Defend,       // Phase 3: Identify injection attack
}

// ── Finding Model ──────────────────────────────────────────

class FindingModel {
  final String hallucinationId;
  final String description;
  final String sourceId;
  final String explanation;
  final bool isCorrect;
  final bool isFalsePositive;

  const FindingModel({
    required this.hallucinationId,
    required this.description,
    required this.sourceId,
    required this.explanation,
    required this.isCorrect,
    required this.isFalsePositive,
  });
}

// ── Injection Response Model ───────────────────────────────

class InjectionResponseModel {
  final String injectionId;
  final String selectedOptionId;
  final bool isCorrect;
  final String explanation;

  const InjectionResponseModel({
    required this.injectionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.explanation,
  });
}

// ── The Controller ─────────────────────────────────────────

class AcademyController extends ChangeNotifier {
  // Flow state
  AcademyFlowState _flowState = AcademyFlowState.academyHome;

  // Phase tracking
  ExperimentPhase _currentPhase = ExperimentPhase.phase1Prompt;

  // Telemetry
  final MissionTelemetry _telemetry = MissionTelemetry();

  // Phase 1: Prompt
  String _promptText = '';
  bool _promptSubmitted = false;
  bool _promptRevisedAfterGeneration = false;

  // Phase 2: Findings
  final List<FindingModel> _findings = [];
  bool _sourceOpened = false;

  // Phase 3: Injection
  InjectionResponseModel? _injectionResponse;

  // Assessment
  AssessmentResult? _assessmentResult;

  // Capability scores (persisted across experiments)
  final Map<String, double> _scores = {};
  final Map<String, double> _previousScores = {};

  AcademyController() {
    _initBaselineScores();
  }

  void _initBaselineScores() {
    for (final cap in CapabilityRegistry.capabilities) {
      _scores[cap.id] = cap.baselineScore;
      _previousScores[cap.id] = cap.baselineScore;
    }
  }

  // ── Getters ──────────────────────────────────────────────

  AcademyFlowState get flowState => _flowState;
  ExperimentPhase get currentPhase => _currentPhase;
  AssessmentResult? get assessmentResult => _assessmentResult;
  Map<String, double> get scores => Map.unmodifiable(_scores);
  Map<String, double> get previousScores => Map.unmodifiable(_previousScores);
  String get promptText => _promptText;
  bool get promptSubmitted => _promptSubmitted;
  bool get promptRevisedAfterGeneration => _promptRevisedAfterGeneration;
  List<FindingModel> get findings => List.unmodifiable(_findings);
  bool get sourceOpened => _sourceOpened;
  InjectionResponseModel? get injectionResponse => _injectionResponse;

  double scoreFor(String capabilityId) => _scores[capabilityId] ?? 0.0;
  double previousScoreFor(String capabilityId) =>
      _previousScores[capabilityId] ?? 0.0;
  double deltaFor(String capabilityId) =>
      scoreFor(capabilityId) - previousScoreFor(capabilityId);

  /// Returns the signal names that were activated for a capability,
  /// for use in AI explanation generation.
  List<String> activatedSignalNamesFor(String capabilityId) {
    final delta = _assessmentResult?.deltaFor(capabilityId);
    if (delta == null) return [];
    return delta.activatedSignals.map((s) => s.signalName).toList();
  }

  // ── Phase 1: Prompt Actions ──────────────────────────────

  void submitPrompt(String text) {
    if (_flowState != AcademyFlowState.experimentActive) return;
    _promptText = text;
    _promptSubmitted = true;

    _telemetry.promptLength = text.length;

    final constraints = _countPromptConstraints(text);
    _telemetry.promptConstraintsCount = constraints;
    _telemetry.outputFormatRequested =
        text.toLowerCase().contains('format') ||
        text.toLowerCase().contains('structure') ||
        text.toLowerCase().contains('table');

    notifyListeners();
  }

  void revisePrompt(String text) {
    _promptText = text;
    _promptRevisedAfterGeneration = true;
    _telemetry.promptRevised = true;
    _telemetry.promptLength = text.length;
    _telemetry.promptConstraintsCount = _countPromptConstraints(text);
    notifyListeners();
  }

  int _countPromptConstraints(String text) {
    int count = 0;
    final lower = text.toLowerCase();
    if (lower.contains('statistic') || lower.contains('data') || lower.contains('angka')) count++;
    if (lower.contains('manufacturer') || lower.contains('produsen')) count++;
    if (lower.contains('policy') || lower.contains('kebijakan') || lower.contains('target')) count++;
    if (lower.contains('export') || lower.contains('ekspor')) count++;
    if (lower.contains('year') || lower.contains('tahun') || lower.contains('2025')) count++;
    return count;
  }

  // ── Phase 2: Verifying Findings Actions ──────────────────

  void openSource() {
    _sourceOpened = true;
    _telemetry.sourceOpened = true;
    _telemetry.uniqueSourcesOpened++;
    notifyListeners();
  }

  void addFinding({
    required String hallucinationId,
    required String description,
    required String sourceId,
    required String explanation,
  }) {
    // Verify against answer key
    final answerKey = Experiment001.hallucinations.firstWhere(
      (h) => h['id'] == hallucinationId,
      orElse: () => <String, dynamic>{},
    );

    final isCorrect = answerKey['id'] != null;
    final isFalsePositive = !isCorrect;

    final finding = FindingModel(
      hallucinationId: hallucinationId,
      description: description,
      sourceId: sourceId,
      explanation: explanation,
      isCorrect: isCorrect,
      isFalsePositive: isFalsePositive,
    );

    _findings.add(finding);

    // Update telemetry
    if (isCorrect) {
      _telemetry.hallucinationsFound++;
      _telemetry.correctFindings++;
    }
    if (isFalsePositive) {
      _telemetry.falsePositiveCount++;
    }
    _telemetry.totalFindingsSubmitted++;
    _telemetry.hasSourceCitation = sourceId.isNotEmpty;
    _telemetry.findingTextLength = description.length + explanation.length;

    notifyListeners();
  }

  // ── Phase 3: Injection Response Actions ──────────────────

  void submitInjectionResponse({
    required String injectionId,
    required String selectedOptionId,
    required String explanation,
  }) {
    final scenario = Experiment001.injectionScenarios.firstWhere(
      (s) => s['id'] == injectionId,
      orElse: () => <String, dynamic>{},
    );

    var isCorrect = false;
    if (scenario['options'] is List) {
      final options = scenario['options'] as List;
      for (final opt in options) {
        if (opt['id'] == selectedOptionId && opt['isCorrect'] == true) {
          isCorrect = true;
          break;
        }
      }
    }

    _injectionResponse = InjectionResponseModel(
      injectionId: injectionId,
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
      explanation: explanation,
    );

    _telemetry.injectionIdentified = isCorrect;
    _telemetry.defenseActionCorrect = isCorrect;
    _telemetry.explanationLength = explanation.length;
    _telemetry.findingStructureQuality = explanation.length >= 50 ? 3 : 1;

    notifyListeners();
  }

  // ── Experiment Flow Actions ──────────────────────────────

  void beginExperiment() {
    _flowState = AcademyFlowState.experimentActive;
    _currentPhase = ExperimentPhase.phase1Prompt;
    _telemetry.reset();
    _promptText = '';
    _promptSubmitted = false;
    _promptRevisedAfterGeneration = false;
    _findings.clear();
    _sourceOpened = false;
    _injectionResponse = null;
    _assessmentResult = null;
    notifyListeners();
  }

  void advancePhase() {
    switch (_currentPhase) {
      case ExperimentPhase.phase1Prompt:
        _currentPhase = ExperimentPhase.phase2Verify;
        _telemetry.logicalTaskOrder = true;
      case ExperimentPhase.phase2Verify:
        _currentPhase = ExperimentPhase.phase3Defend;
      case ExperimentPhase.phase3Defend:
        // All phases complete
        break;
    }
    notifyListeners();
  }

  void submitAllFindings() {
    _flowState = AcademyFlowState.experimentComplete;
    _runAssessment();
    notifyListeners();
  }

  void _runAssessment() {
    _previousScores
      ..clear()
      ..addAll(_scores);

    final engine = AssessmentEngine();
    final allSignals = <Map<String, dynamic>>[
      ...Experiment001.phase1Signals,
      ...Experiment001.phase2Signals,
      ...Experiment001.phase3Signals,
    ];

    _assessmentResult = engine.evaluate(
      _telemetry,
      allSignals,
      _scores,
    );

    // Apply deltas
    for (final delta in _assessmentResult!.deltas) {
      _scores[delta.capabilityId] = delta.newScore;
    }

    _flowState = AcademyFlowState.summaryReady;
    notifyListeners();
  }

  void viewDashboard() {
    _flowState = AcademyFlowState.dashboardReady;
    notifyListeners();
  }

  void returnToAcademy() {
    _flowState = AcademyFlowState.academyHome;
    notifyListeners();
  }

  // ── AI Explanation Generation ────────────────────────────
  //
  // Layer 3: AI generates natural language explanations from
  // deterministic assessment results. This will eventually be
  // replaced with real LLM-generated text, but the engine
  // never modifies scores — it only explains them.
  //
  // For MVP, explanations are template-based from signal names.
  // This keeps zero AI dependencies while faithfully
  // representing the three-layer architecture.

  String generateExplanationFor(String capabilityId) {
    final delta = _assessmentResult?.deltaFor(capabilityId);
    if (delta == null || delta.activatedSignals.isEmpty) {
      return 'No new signals were observed for ${CapabilityRegistry.byId(capabilityId)?.name ?? capabilityId} during this experiment.';
    }

    final signalNames = delta.activatedSignals.map((s) => s.signalName).toList();
    final signalsText = _formatSignalList(signalNames);

    if (delta.delta > 0) {
      return 'Your ${delta.capabilityName} increased because you $signalsText.';
    } else if (delta.delta < 0) {
      return 'Your ${delta.capabilityName} changed because you $signalsText.';
    } else {
      return 'Your ${delta.capabilityName} remained stable. $signalsText — these signals balanced each other.';
    }
  }

  String _formatSignalList(List<String> names) {
    if (names.isEmpty) return 'demonstrated no measurable behaviors';
    if (names.length == 1) return names.first.toLowerCase();
    if (names.length == 2) {
      return '${names[0].toLowerCase()} and ${names[1].toLowerCase()}';
    }
    final allButLast = names.sublist(0, names.length - 1);
    final last = names.last;
    return '${allButLast.map((n) => n.toLowerCase()).join(', ')}, and ${last.toLowerCase()}';
  }
}
