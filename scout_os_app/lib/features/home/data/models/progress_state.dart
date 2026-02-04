// Progress State Models
//
// Models for user progress tracking.
// Matches backend progress state response (when implemented).

// Level Progress State
class LevelProgressState {
  final String levelId;
  final String status; // "locked" | "available" | "in_progress" | "completed"
  final double progress; // 0.0 to 1.0
  final int? score; // null if not completed
  final DateTime? completedAt; // null if not completed

  LevelProgressState({
    required this.levelId,
    required this.status,
    required this.progress,
    this.score,
    this.completedAt,
  });

  factory LevelProgressState.fromJson(Map<String, dynamic> json) {
    return LevelProgressState(
      levelId: json['level_id'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      score: json['score'] as int?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}

/// Unit Progress State
class UnitProgressState {
  final String unitId;
  final List<LevelProgressState> levels;

  UnitProgressState({
    required this.unitId,
    required this.levels,
  });

  factory UnitProgressState.fromJson(Map<String, dynamic> json) {
    return UnitProgressState(
      unitId: json['unit_id'] as String,
      levels: (json['levels'] as List<dynamic>?)
              ?.map((item) => LevelProgressState.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Section Progress State
class SectionProgressState {
  final String sectionId;
  final bool isUnlocked;
  final List<UnitProgressState> units;

  SectionProgressState({
    required this.sectionId,
    required this.isUnlocked,
    required this.units,
  });

  factory SectionProgressState.fromJson(Map<String, dynamic> json) {
    return SectionProgressState(
      sectionId: json['section_id'] as String,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      units: (json['units'] as List<dynamic>?)
              ?.map((item) => UnitProgressState.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Progress State Response (Root)
class ProgressStateResponse {
  final List<SectionProgressState> sections;

  ProgressStateResponse({
    required this.sections,
  });

  factory ProgressStateResponse.fromJson(Map<String, dynamic> json) {
    return ProgressStateResponse(
      sections: (json['sections'] as List<dynamic>?)
              ?.map((item) => SectionProgressState.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Helper: Get level progress by level ID
  LevelProgressState? getLevelProgress(String levelId) {
    for (final section in sections) {
      for (final unit in section.units) {
        for (final level in unit.levels) {
          if (level.levelId == levelId) {
            return level;
          }
        }
      }
    }
    return null;
  }
}
