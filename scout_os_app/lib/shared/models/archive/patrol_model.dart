class PatrolModel {
  final String id;
  final String name;
  final List<String> memberIds;
  final String leaderId;
  final String formationReason;
  final DateTime formedAt;

  PatrolModel({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.leaderId,
    required this.formationReason,
    required this.formedAt,
  });

  factory PatrolModel.fromJson(Map<String, dynamic> json) {
    return PatrolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      memberIds: List<String>.from(json['member_ids'] as List),
      leaderId: json['leader_id'] as String,
      formationReason: json['formation_reason'] as String,
      formedAt: DateTime.parse(json['formed_at'] as String),
    );
  }
}
