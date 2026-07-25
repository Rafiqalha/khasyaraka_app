class AssessmentModel {
  final String id;
  final String operationId;
  final String userId;
  final double score;
  final String aiFeedback;
  final Map<String, double> capabilityDelta;
  final DateTime assessedAt;

  AssessmentModel({
    required this.id,
    required this.operationId,
    required this.userId,
    required this.score,
    required this.aiFeedback,
    required this.capabilityDelta,
    required this.assessedAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      operationId: json['operation_id'] as String,
      userId: json['user_id'] as String,
      score: (json['score'] as num).toDouble(),
      aiFeedback: json['ai_feedback'] as String,
      capabilityDelta: Map<String, double>.from(json['capability_delta'] as Map),
      assessedAt: DateTime.parse(json['assessed_at'] as String),
    );
  }
}
