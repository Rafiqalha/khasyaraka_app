/// Training Level Model
/// 
/// 1:1 mapping with backend TrainingLevelResponse schema.
/// DO NOT modify field names or types - must match backend exactly.
class TrainingLevel {
  final String id;
  final String unitId;
  final int levelNumber;
  final String difficulty; // "very_easy" | "easy" | "medium" | "hard"
  final int totalQuestions;
  final int minCorrect;
  final int xpReward;
  final Map<String, dynamic>? unlockRule;
  final bool isActive;
  final DateTime createdAt;

  TrainingLevel({
    required this.id,
    required this.unitId,
    required this.levelNumber,
    required this.difficulty,
    required this.totalQuestions,
    required this.minCorrect,
    required this.xpReward,
    this.unlockRule,
    required this.isActive,
    required this.createdAt,
  });

  /// Parse from backend API response
  /// Matches: GET /training/units/{id}/levels
  factory TrainingLevel.fromJson(Map<String, dynamic> json) {
    return TrainingLevel(
      id: json['id'] as String,
      unitId: json['unit_id'] as String,
      levelNumber: json['level_number'] as int,
      difficulty: json['difficulty'] as String? ?? 'easy',
      totalQuestions: json['total_questions'] as int? ?? 5,
      minCorrect: json['min_correct'] as int? ?? 4,
      xpReward: json['xp_reward'] as int? ?? 10,
      unlockRule: json['unlock_rule'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'level_number': levelNumber,
      'difficulty': difficulty,
      'total_questions': totalQuestions,
      'min_correct': minCorrect,
      'xp_reward': xpReward,
      'unlock_rule': unlockRule,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Level List Response
/// Matches: GET /training/units/{id}/levels response
class LevelListResponse {
  final int total;
  final String unitId;
  final List<TrainingLevel> levels;

  LevelListResponse({
    required this.total,
    required this.unitId,
    required this.levels,
  });

  factory LevelListResponse.fromJson(Map<String, dynamic> json) {
    return LevelListResponse(
      total: json['total'] as int,
      unitId: json['unit_id'] as String,
      levels: (json['levels'] as List<dynamic>)
          .map((item) => TrainingLevel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Path Level Schema (for Learning Path endpoint)
/// Matches: GET /training/sections/{id}/path response
class PathLevel {
  final String levelId;
  final String title;
  final int levelNumber;
  final String difficulty;
  final int xpReward;
  final String status; // "locked" | "available" | "in_progress" | "completed"

  PathLevel({
    required this.levelId,
    required this.title,
    required this.levelNumber,
    required this.difficulty,
    required this.xpReward,
    required this.status,
  });

  factory PathLevel.fromJson(Map<String, dynamic> json) {
    return PathLevel(
      levelId: json['level_id'] as String,
      title: json['title'] as String,
      levelNumber: json['level_number'] as int,
      difficulty: json['difficulty'] as String,
      xpReward: json['xp_reward'] as int,
      status: json['status'] as String? ?? 'locked',
    );
  }
}
