import 'academy_model.dart';

class DirectorInsight {
  final String observation;
  final String motivation;
  final String strategy;
  final String reflection;

  DirectorInsight({
    required this.observation,
    required this.motivation,
    required this.strategy,
    required this.reflection,
  });

  factory DirectorInsight.fromJson(Map<String, dynamic> json) {
    return DirectorInsight(
      observation: json['observation'] ?? '',
      motivation: json['motivation'] ?? '',
      strategy: json['strategy'] ?? '',
      reflection: json['reflection'] ?? '',
    );
  }
}

class DirectorBrief {
  final String yesterday;
  final String today;
  final String risk;
  final String focus;
  final String expectedOutcome;

  DirectorBrief({
    required this.yesterday,
    required this.today,
    required this.risk,
    required this.focus,
    required this.expectedOutcome,
  });

  factory DirectorBrief.fromJson(Map<String, dynamic> json) {
    return DirectorBrief(
      yesterday: json['yesterday'] ?? '',
      today: json['today'] ?? '',
      risk: json['risk'] ?? '',
      focus: json['focus'] ?? '',
      expectedOutcome: json['expected_outcome'] ?? '',
    );
  }
}

class ActiveRuntimeModel {
  final String runtimeId;
  final String title;
  final String status; // RUNNING, PAUSED, WAITING, COMPILING, GENERATING
  final String currentObjective;
  final String lastActivityText;
  final String estimatedDuration; // Planner-calculated
  final String userDifficulty;    // Planner-calculated
  final DirectorBrief? directorBrief;

  ActiveRuntimeModel({
    required this.runtimeId,
    required this.title,
    required this.status,
    required this.currentObjective,
    required this.lastActivityText,
    required this.estimatedDuration,
    required this.userDifficulty,
    this.directorBrief,
  });

  factory ActiveRuntimeModel.fromJson(Map<String, dynamic> json) {
    return ActiveRuntimeModel(
      runtimeId: json['runtime_id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'NONE',
      currentObjective: json['current_objective'] ?? '',
      lastActivityText: json['last_activity_text'] ?? '',
      estimatedDuration: json['estimated_duration'] ?? '',
      userDifficulty: json['user_difficulty'] ?? '',
      directorBrief: json['director_brief'] != null
          ? DirectorBrief.fromJson(json['director_brief'])
          : null,
    );
  }
}

class ActiveJourneyModel {
  final String enrollmentId;
  final String blueprintVersion;
  final String specialization;
  final double capabilityScore;
  final String? runtimeSessionId;
  final String? currentMission;

  ActiveJourneyModel({
    required this.enrollmentId,
    required this.blueprintVersion,
    required this.specialization,
    required this.capabilityScore,
    this.runtimeSessionId,
    this.currentMission,
  });

  factory ActiveJourneyModel.fromJson(Map<String, dynamic> json) {
    return ActiveJourneyModel(
      enrollmentId: json['enrollment_id'] ?? '',
      blueprintVersion: json['blueprint_version'] ?? '',
      specialization: json['specialization'] ?? '',
      capabilityScore: (json['capability_score'] as num?)?.toDouble() ?? 0.0,
      runtimeSessionId: json['runtime_session_id'],
      currentMission: json['current_mission'],
    );
  }
}

class HomeDataModel {
  final bool requiresInitialization;
  final bool isCalculating;
  final String? goalTitle;
  final String? currentNode;
  final int? masteredCompetencies;
  final int? remainingCompetencies;
  final List<String>? currentUnderstanding;
  final List<String>? missingCompetencies;
  final DirectorInsight? directorInsight;
  final ActiveJourneyModel? activeJourney;
  final ActiveRuntimeModel? activeRuntime;
  final int knowledgeUpdateCount;
  final List<AcademyModel>? launcher;

  HomeDataModel({
    required this.requiresInitialization,
    this.isCalculating = false,
    this.goalTitle,
    this.currentNode,
    this.masteredCompetencies,
    this.remainingCompetencies,
    this.currentUnderstanding,
    this.missingCompetencies,
    this.directorInsight,
    this.activeJourney,
    this.activeRuntime,
    this.knowledgeUpdateCount = 0,
    this.launcher,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      requiresInitialization: json['requires_initialization'] ?? false,
      isCalculating: json['is_calculating'] ?? false,
      goalTitle: json['goal_title'],
      currentNode: json['current_node'],
      masteredCompetencies: json['mastered_competencies'],
      remainingCompetencies: json['remaining_competencies'],
      currentUnderstanding: json['current_understanding'] != null 
          ? List<String>.from(json['current_understanding']) 
          : null,
      missingCompetencies: json['missing_competencies'] != null
          ? List<String>.from(json['missing_competencies'])
          : null,
      directorInsight: json['director_insight'] != null 
          ? DirectorInsight.fromJson(json['director_insight']) 
          : null,
      activeJourney: json['active_journey'] != null
          ? ActiveJourneyModel.fromJson(json['active_journey'])
          : null,
      activeRuntime: json['active_runtime'] != null
          ? ActiveRuntimeModel.fromJson(json['active_runtime'])
          : null,
      knowledgeUpdateCount: json['knowledge_update_count'] ?? 0,
      launcher: json['launcher'] != null 
          ? (json['launcher'] as List).map((i) => AcademyModel.fromJson(i)).toList()
          : null,
    );
  }
}
