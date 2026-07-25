class SubmissionResponseDto {
  final String submissionId;
  final String verdict;
  final String feedback;
  final List<EvidenceDto> evidence;
  final CompetencyDeltaDto? competencyDelta;
  final NextNodeDto? nextNode;
  final AiAnalysisDto? aiAnalysis;

  const SubmissionResponseDto({
    required this.submissionId,
    required this.verdict,
    required this.feedback,
    this.evidence = const [],
    this.competencyDelta,
    this.nextNode,
    this.aiAnalysis,
  });

  factory SubmissionResponseDto.fromJson(Map<String, dynamic> json) {
    return SubmissionResponseDto(
      submissionId: json['submissionId'],
      verdict: json['verdict'],
      feedback: json['feedback'] ?? json['recommendation']?['message'] ?? '',
      evidence: (json['evidence'] as List? ?? []).map((e) => EvidenceDto.fromJson(e)).toList(),
      competencyDelta: json['competencyDelta'] != null ? CompetencyDeltaDto.fromJson(json['competencyDelta']) : null,
      nextNode: json['nextNode'] != null ? NextNodeDto.fromJson(json['nextNode']) : json['recommendation'] != null ? NextNodeDto.fromJson(json['recommendation']) : null,
      aiAnalysis: json['ai_analysis'] != null ? AiAnalysisDto.fromJson(json['ai_analysis']) : null,
    );
  }
}

class AiAnalysisDto {
  final String diagnosis;
  final String suggestion;
  final List<String> references;
  final double confidence;

  const AiAnalysisDto({
    required this.diagnosis,
    required this.suggestion,
    this.references = const [],
    this.confidence = 0.0,
  });

  factory AiAnalysisDto.fromJson(Map<String, dynamic> json) {
    return AiAnalysisDto(
      diagnosis: json['diagnosis'] ?? '',
      suggestion: json['suggestion'] ?? '',
      references: (json['references'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EvidenceDto {
  final String id;
  final String nodeId;
  final String competencyId;
  final double score;

  const EvidenceDto({
    required this.id,
    required this.nodeId,
    required this.competencyId,
    required this.score,
  });

  factory EvidenceDto.fromJson(Map<String, dynamic> json) {
    return EvidenceDto(
      id: json['id'] ?? '',
      nodeId: json['nodeId'] ?? json['observation_id'] ?? '',
      competencyId: json['competencyId'] ?? json['evidence_type'] ?? '',
      score: (json['score'] ?? json['strength'] ?? 0.0).toDouble(),
    );
  }
}

class CompetencyDeltaDto {
  final String competencyId;
  final String competencyName;
  final double oldScore;
  final double newScore;

  const CompetencyDeltaDto({
    required this.competencyId,
    required this.competencyName,
    required this.oldScore,
    required this.newScore,
  });

  factory CompetencyDeltaDto.fromJson(Map<String, dynamic> json) {
    return CompetencyDeltaDto(
      competencyId: json['competencyId'],
      competencyName: json['competencyName'],
      oldScore: (json['oldScore'] as num).toDouble(),
      newScore: (json['newScore'] as num).toDouble(),
    );
  }
}

class NextNodeDto {
  final String id;
  final String type;
  final bool locked;
  final String reason;
  final Map<String, dynamic> metadata;

  const NextNodeDto({
    required this.id,
    required this.type,
    required this.locked,
    required this.reason,
    required this.metadata,
  });

  factory NextNodeDto.fromJson(Map<String, dynamic> json) {
    return NextNodeDto(
      id: json['id'] ?? json['targetNode'] ?? '',
      type: json['type'] ?? 'MISSION',
      locked: json['locked'] ?? false,
      reason: json['reason'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }
}

class SubmissionStatusResponseDto {
  final String submissionId;
  final String status;
  final int progress;
  final String step;
  // Payload when COMPLETED
  final SubmissionResponseDto? result;

  const SubmissionStatusResponseDto({
    required this.submissionId,
    required this.status,
    required this.progress,
    this.step = '',
    this.result,
  });

  factory SubmissionStatusResponseDto.fromJson(Map<String, dynamic> json) {
    return SubmissionStatusResponseDto(
      submissionId: json['submissionId'],
      status: json['status'],
      progress: json['progress'] ?? 0,
      step: json['step'] ?? json['status'], // Fallback to status if step is missing
      result: json['result'] != null ? SubmissionResponseDto.fromJson(json['result']) : null,
    );
  }
}

