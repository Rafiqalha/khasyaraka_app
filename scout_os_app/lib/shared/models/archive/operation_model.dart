enum OperationState { generating, ready, running, evaluating, completed, failed }

class OperationModel {
  final String id;
  final String missionId;
  final String userId;
  final OperationState state;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? artifacts;

  OperationModel({
    required this.id,
    required this.missionId,
    required this.userId,
    required this.state,
    required this.startedAt,
    this.completedAt,
    this.artifacts,
  });

  factory OperationModel.fromJson(Map<String, dynamic> json) {
    return OperationModel(
      id: json['id'] as String,
      missionId: json['mission_id'] as String,
      userId: json['user_id'] as String,
      state: OperationState.values.firstWhere(
          (e) => e.toString().split('.').last == json['state'],
          orElse: () => OperationState.ready),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      artifacts: json['artifacts'] as Map<String, dynamic>?,
    );
  }
}
