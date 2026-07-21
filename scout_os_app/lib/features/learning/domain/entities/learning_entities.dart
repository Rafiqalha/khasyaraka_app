// Pure Domain Entities for Learning Client Architecture

class Journey {
  final String id;
  final String title;
  final List<JourneyNode> nodes;
  final bool isCompleted;

  const Journey({
    required this.id,
    required this.title,
    required this.nodes,
    this.isCompleted = false,
  });
}

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

class Assessment {
  final String id;
  final String title;
  final List<Question> questions;

  const Assessment({
    required this.id,
    required this.title,
    required this.questions,
  });
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final String correctOption;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOption,
  });
}

class Mission {
  final String id;
  final String title;
  final String objective;
  final String concept;
  final String difficulty;
  final String initialCode;

  const Mission({
    required this.id,
    required this.title,
    required this.objective,
    required this.concept,
    required this.difficulty,
    required this.initialCode,
  });
}

class Evidence {
  final String id;
  final String nodeId;
  final String competencyId;
  final double score;
  final DateTime capturedAt;

  const Evidence({
    required this.id,
    required this.nodeId,
    required this.competencyId,
    required this.score,
    required this.capturedAt,
  });
}

class CompetencyDelta {
  final String competencyId;
  final String competencyName;
  final double oldScore;
  final double newScore;

  const CompetencyDelta({
    required this.competencyId,
    required this.competencyName,
    required this.oldScore,
    required this.newScore,
  });
}

class Passport {
  final String studentId;
  final List<CompetencyDelta> recentDeltas;
  final String nextRecommendationId;

  const Passport({
    required this.studentId,
    required this.recentDeltas,
    required this.nextRecommendationId,
  });
}

// TelemetryEvent is defined in core/telemetry/telemetry.dart, but conceptually part of the domain.
