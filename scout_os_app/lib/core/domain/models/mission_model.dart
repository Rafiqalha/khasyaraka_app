class MissionModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isCompleted;
  final String? targetedCapability;
  final String? reason;
  final String? difficulty;
  final double? estimatedSuccess;
  final DateTime? generatedAt;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isCompleted = false,
    this.targetedCapability,
    this.reason,
    this.difficulty,
    this.estimatedSuccess,
    this.generatedAt,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      targetedCapability: json['targeted_capability'],
      reason: json['reason'],
      difficulty: json['difficulty'],
      estimatedSuccess: (json['estimated_success'] as num?)?.toDouble(),
      generatedAt: json['generated_at'] != null ? DateTime.tryParse(json['generated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'is_completed': isCompleted,
    };
  }
}
