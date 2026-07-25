class CapabilityModel {
  final String userId;
  final double detection;
  final double investigation;
  final double reasoning;
  final double communication;
  final double automation;
  final double leadership;

  CapabilityModel({
    required this.userId,
    required this.detection,
    required this.investigation,
    required this.reasoning,
    required this.communication,
    required this.automation,
    required this.leadership,
  });

  factory CapabilityModel.fromJson(Map<String, dynamic> json) {
    return CapabilityModel(
      userId: json['user_id'] ?? '',
      detection: (json['detection'] as num?)?.toDouble() ?? 0.0,
      investigation: (json['investigation'] as num?)?.toDouble() ?? 0.0,
      reasoning: (json['reasoning'] as num?)?.toDouble() ?? 0.0,
      communication: (json['communication'] as num?)?.toDouble() ?? 0.0,
      automation: (json['automation'] as num?)?.toDouble() ?? 0.0,
      leadership: (json['leadership'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'detection': detection,
      'investigation': investigation,
      'reasoning': reasoning,
      'communication': communication,
      'automation': automation,
      'leadership': leadership,
    };
  }
}
