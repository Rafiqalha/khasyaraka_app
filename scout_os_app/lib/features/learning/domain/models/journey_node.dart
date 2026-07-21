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

  const JourneyNode({
    required this.id,
    required this.type,
    required this.title,
    this.isCompleted = false,
  });
}
