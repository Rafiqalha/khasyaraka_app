// Pure Domain Entities for Learning Client Architecture

typedef Journey = LearningGoal;
typedef JourneyNode = RuntimeActivity;

class LearningGoal {
  final String id;
  final String title;
  final List<RuntimeActivity> activities;
  final bool isCompleted;

  const LearningGoal({
    required this.id,
    required this.title,
    required this.activities,
    this.isCompleted = false,
  });
}

enum NodeType {
  preAssessment,
  journeyMap,
  notebook,
  mission,
  sandbox,
  postAssessment,
  lookingBack,
  passport,
}

enum NodeLifecycle {
  enter,
  build,
  interact,
  complete,
  exit,
}

class RuntimeActivity {
  final String id;
  final NodeType type;
  final String title;
  final bool isCompleted;
  final Duration estimatedDuration;
  final bool isRequired;
  final String telemetryKey;

  const RuntimeActivity({
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

enum LearningSessionStatus {
  active,
  paused,
  completed,
  abandoned,
}

class LearningSession {
  final String sessionId;
  final String userId;
  final String learningGoalId;
  final String activityId;
  final DateTime startedAt;
  final DateTime lastInteractionAt;
  final String deviceId;
  final String appVersion;
  final String platform;
  final String locale;
  final Duration elapsedTime;
  final int attempt;
  final String telemetrySessionId;
  final LearningSessionStatus status;

  const LearningSession({
    required this.sessionId,
    required this.userId,
    required this.learningGoalId,
    required this.activityId,
    required this.startedAt,
    required this.lastInteractionAt,
    required this.deviceId,
    required this.appVersion,
    required this.platform,
    required this.locale,
    required this.elapsedTime,
    required this.attempt,
    required this.telemetrySessionId,
    required this.status,
  });

  LearningSession copyWith({
    String? sessionId,
    String? userId,
    String? learningGoalId,
    String? activityId,
    DateTime? startedAt,
    DateTime? lastInteractionAt,
    String? deviceId,
    String? appVersion,
    String? platform,
    String? locale,
    Duration? elapsedTime,
    int? attempt,
    String? telemetrySessionId,
    LearningSessionStatus? status,
  }) {
    return LearningSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      learningGoalId: learningGoalId ?? this.learningGoalId,
      activityId: activityId ?? this.activityId,
      startedAt: startedAt ?? this.startedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      locale: locale ?? this.locale,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      attempt: attempt ?? this.attempt,
      telemetrySessionId: telemetrySessionId ?? this.telemetrySessionId,
      status: status ?? this.status,
    );
  }
}
