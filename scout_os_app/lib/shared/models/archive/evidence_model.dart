class EvidenceModel {
  final String id;
  final String missionId;
  final String type; // log, packet, timeline, memory
  final String content;
  final int requiredCapabilityLevel;

  EvidenceModel({
    required this.id,
    required this.missionId,
    required this.type,
    required this.content,
    required this.requiredCapabilityLevel,
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      id: json['id'] as String,
      missionId: json['mission_id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      requiredCapabilityLevel: json['required_capability_level'] as int,
    );
  }
}
