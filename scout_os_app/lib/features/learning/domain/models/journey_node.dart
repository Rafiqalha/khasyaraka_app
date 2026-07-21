enum NodeType {
  preAssessment,
  journeyMap,
  notebook,
  quickCheck,
  sandbox,
  mission,
  thinking,
  postAssessment,
  lookingBack,
  passport,
}

class JourneyNode {
  final String id;
  final NodeType type;
  final String title;
  final bool isCompleted;
  
  // G1.5 Validation Metadata Requirements
  final Duration estimatedDuration;
  final bool isRequired;
  final String telemetryKey;

  const JourneyNode({
    required this.id,
    required this.type,
    required this.title,
    this.isCompleted = false,
    required this.estimatedDuration,
    required this.isRequired,
    required this.telemetryKey,
  });
}
