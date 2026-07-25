// Pradigi OS — Assessment Engine (Layer 2: Deterministic Rule Engine)
//
// This engine evaluates domain-agnostic behavioral telemetry against
// user-facing capability configurations and experiment signal definitions.
//
// CRITICAL CONSTRAINT: This engine has ZERO knowledge of experiment content.
// It does not know about articles, spreadsheets, EV industry data,
// prompt injection payloads, or any domain specifics. It only evaluates
// signals defined in configuration against collected telemetry.
//
// Layer 1 → Observable telemetry (collected by the workspace)
// Layer 2 → THIS ENGINE (deterministic, reproducible, no AI)
// Layer 3 → AI explanation (generated after assessment, never scores)

import '../../../core/config/capability_config.dart';

/// Result from evaluating a single capability signal against telemetry.
/// Immutable — create a new instance if data changes.
class SignalResult {
  final String signalId;
  final String signalName;
  final double weight;
  final SignalConfidence confidence;
  final bool activated;

  const SignalResult({
    required this.signalId,
    required this.signalName,
    required this.weight,
    required this.confidence,
    required this.activated,
  });
}

/// Delta for a single capability dimension after one experiment.
/// Immutable — create a new instance if data changes.
class CapabilityDelta {
  final String capabilityId;
  final String capabilityName;
  final double delta;
  final double oldScore;
  final double newScore;
  final List<SignalResult> activatedSignals;
  final double confidence;

  const CapabilityDelta({
    required this.capabilityId,
    required this.capabilityName,
    required this.delta,
    required this.oldScore,
    required this.newScore,
    required this.activatedSignals,
    required this.confidence,
  });
}

/// Complete assessment result for an experiment.
/// Immutable — create a new instance if data changes.
class AssessmentResult {
  final List<CapabilityDelta> deltas;

  const AssessmentResult({required this.deltas});

  CapabilityDelta? deltaFor(String capabilityId) {
    try {
      return deltas.firstWhere((d) => d.capabilityId == capabilityId);
    } catch (_) {
      return null;
    }
  }
}

/// Raw telemetry collected during an experiment.
///
/// This is the domain-agnostic data structure that sits between the
/// workspace (which records user actions) and the assessment engine
/// (which evaluates signals). The workspace translates user actions
/// into counts, flags, and timestamps. The engine reads those numbers.
class MissionTelemetry {
  int promptConstraintsCount;
  bool promptRevised;
  int promptLength;
  bool outputFormatRequested;
  bool logicalTaskOrder;

  int hallucinationsFound;
  int hallucinationsTotal;
  int falsePositiveCount;
  bool sourceOpened;
  int uniqueSourcesOpened;
  int findingTextLength;
  bool hasSourceCitation;
  int totalFindingsSubmitted;
  int correctFindings;
  bool aiOutputReviewed;

  bool injectionIdentified;
  bool defenseActionCorrect;
  int explanationLength;
  int findingStructureQuality;

  MissionTelemetry({
    this.promptConstraintsCount = 0,
    this.promptRevised = false,
    this.promptLength = 0,
    this.outputFormatRequested = false,
    this.logicalTaskOrder = false,
    this.hallucinationsFound = 0,
    this.hallucinationsTotal = 0,
    this.falsePositiveCount = 0,
    this.sourceOpened = false,
    this.uniqueSourcesOpened = 0,
    this.findingTextLength = 0,
    this.hasSourceCitation = false,
    this.totalFindingsSubmitted = 0,
    this.correctFindings = 0,
    this.aiOutputReviewed = false,
    this.injectionIdentified = false,
    this.defenseActionCorrect = false,
    this.explanationLength = 0,
    this.findingStructureQuality = 0,
  });

  void reset() {
    promptConstraintsCount = 0;
    promptRevised = false;
    promptLength = 0;
    outputFormatRequested = false;
    logicalTaskOrder = false;
    hallucinationsFound = 0;
    hallucinationsTotal = 0;
    falsePositiveCount = 0;
    sourceOpened = false;
    uniqueSourcesOpened = 0;
    findingTextLength = 0;
    hasSourceCitation = false;
    totalFindingsSubmitted = 0;
    correctFindings = 0;
    aiOutputReviewed = false;
    injectionIdentified = false;
    defenseActionCorrect = false;
    explanationLength = 0;
    findingStructureQuality = 0;
  }

  bool getBool(String field) {
    switch (field) {
      case 'prompt_revised':
        return promptRevised;
      case 'output_format_requested':
        return outputFormatRequested;
      case 'logical_task_order':
        return logicalTaskOrder;
      case 'source_opened':
        return sourceOpened;
      case 'ai_output_reviewed':
        return aiOutputReviewed;
      case 'has_source_citation':
        return hasSourceCitation;
      case 'injection_identified':
        return injectionIdentified;
      case 'defense_action_correct':
        return defenseActionCorrect;
      default:
        return false;
    }
  }

  int getInt(String field) {
    switch (field) {
      case 'prompt_constraints_count':
        return promptConstraintsCount;
      case 'prompt_length':
        return promptLength;
      case 'hallucinations_found':
        return hallucinationsFound;
      case 'unique_sources_opened':
        return uniqueSourcesOpened;
      case 'unique_sources':
        return uniqueSourcesOpened;
      case 'finding_text_length':
        return findingTextLength;
      case 'explanation_length':
        return explanationLength;
      case 'finding_structure_quality':
        return findingStructureQuality;
      default:
        return 0;
    }
  }

  bool getVerified(String field) {
    switch (field) {
      case 'hallucination_correct':
        return hallucinationsFound > 0;
      case 'false_positive':
        return falsePositiveCount > 0;
      case 'finding_correct':
        return correctFindings > 0;
      case 'injection_identified':
        return injectionIdentified;
      case 'defense_action_correct':
        return defenseActionCorrect;
      default:
        return false;
    }
  }

  int perFindingCount(String field) {
    switch (field) {
      case 'has_citation':
      case 'has_source_citation':
        return hasSourceCitation ? totalFindingsSubmitted : 0;
      case 'references_source_name':
        return hasSourceCitation ? totalFindingsSubmitted : 0;
      case 'has_numeric_comparison':
        return 0;
      default:
        return 0;
    }
  }
}

/// Domain-agnostic signal evaluator.
///
/// Usage:
/// ```dart
/// final engine = AssessmentEngine();
/// final result = engine.evaluate(telemetry, experimentSignals, baselineScores);
/// ```
class AssessmentEngine {
  static const double maxCapabilityDeltaPerExperiment = 0.20;

  AssessmentResult evaluate(
    MissionTelemetry telemetry,
    List<Map<String, dynamic>> signalDefinitions,
    Map<String, double> baselineScores,
  ) {
    final deltasByCapability = <String, double>{};
    final signalsByCapability = <String, List<SignalResult>>{};

    for (final signalDef in signalDefinitions) {
      final signal = _parseSignal(signalDef);
      final capabilityId = signalDef['capability'] as String? ?? '';

      final activated = _evaluate(signal, telemetry);
      final result = SignalResult(
        signalId: signal.id,
        signalName: signal.name,
        weight: signal.weight,
        confidence: signal.confidence,
        activated: activated,
      );

      deltasByCapability.putIfAbsent(capabilityId, () => 0);
      signalsByCapability.putIfAbsent(capabilityId, () => []);

      if (activated) {
        deltasByCapability[capabilityId] =
            (deltasByCapability[capabilityId] ?? 0) + signal.weight;
      }
      signalsByCapability[capabilityId]!.add(result);
    }

    final results = <CapabilityDelta>[];
    for (final entry in deltasByCapability.entries) {
      final capabilityId = entry.key;
      final config = CapabilityRegistry.byId(capabilityId);
      final baseline = baselineScores[capabilityId] ?? 0.0;
      final rawDelta = entry.value;

      final delta = rawDelta.clamp(
        -maxCapabilityDeltaPerExperiment,
        maxCapabilityDeltaPerExperiment,
      );

      final signals = signalsByCapability[capabilityId] ?? [];
      final activatedSignals =
          signals.where((s) => s.activated).toList();
      final confidence = _calculateConfidence(signals);

      results.add(CapabilityDelta(
        capabilityId: capabilityId,
        capabilityName: config?.name ?? capabilityId,
        delta: delta,
        oldScore: baseline,
        newScore: (baseline + delta).clamp(0.0, 1.0),
        activatedSignals: activatedSignals,
        confidence: confidence,
      ));
    }

    return AssessmentResult(deltas: results);
  }

  SignalConfig _parseSignal(Map<String, dynamic> def) {
    final typeStr = def['type'] as String? ?? 'binary';
    final confStr = def['confidence'] as String? ?? 'high';

    return SignalConfig(
      id: def['id'] as String? ?? '',
      name: def['name'] as String? ?? '',
      type: _parseSignalType(typeStr),
      field: def['field'] as String? ?? '',
      expected: def['expected'],
      threshold: def['threshold'] as int? ?? 0,
      weight: (def['weight'] as num?)?.toDouble() ?? 0.0,
      confidence: _parseConfidence(confStr),
    );
  }

  CapabilitySignalType _parseSignalType(String type) {
    switch (type) {
      case 'binary':
        return CapabilitySignalType.binary;
      case 'verified':
        return CapabilitySignalType.verified;
      case 'threshold':
        return CapabilitySignalType.threshold;
      case 'perFinding':
        return CapabilitySignalType.perFinding;
      default:
        return CapabilitySignalType.binary;
    }
  }

  SignalConfidence _parseConfidence(String conf) {
    switch (conf) {
      case 'high':
        return SignalConfidence.high;
      case 'medium':
        return SignalConfidence.medium;
      case 'low':
        return SignalConfidence.low;
      default:
        return SignalConfidence.low;
    }
  }

  bool _evaluate(SignalConfig signal, MissionTelemetry t) {
    switch (signal.type) {
      case CapabilitySignalType.binary:
        return t.getBool(signal.field) == true;
      case CapabilitySignalType.verified:
        final actual = t.getVerified(signal.field);
        final expected = signal.expected;
        if (expected is bool) return actual == expected;
        return actual;
      case CapabilitySignalType.threshold:
        return t.getInt(signal.field) >= signal.threshold;
      case CapabilitySignalType.perFinding:
        return t.perFindingCount(signal.field) >= 1;
    }
  }

  double _calculateConfidence(List<SignalResult> signals) {
    if (signals.isEmpty) return 0.0;
    double total = 0;
    for (final s in signals) {
      total += s.activated ? _confidenceWeight(s.confidence) : 0;
    }
    return total / signals.length;
  }

  double _confidenceWeight(SignalConfidence conf) {
    switch (conf) {
      case SignalConfidence.high:
        return 0.90;
      case SignalConfidence.medium:
        return 0.70;
      case SignalConfidence.low:
        return 0.50;
    }
  }
}
