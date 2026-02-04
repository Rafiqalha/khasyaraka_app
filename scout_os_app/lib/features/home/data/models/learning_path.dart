import 'training_level.dart';

/// Learning Path Response Model
/// 
/// 1:1 mapping with backend LearningPathResponse schema.
/// Used for Duolingo-style training map display.
/// 
/// Matches: GET /training/sections/{id}/path
class LearningPathResponse {
  final String sectionId;
  final String sectionTitle;
  final List<PathUnit> units;

  LearningPathResponse({
    required this.sectionId,
    required this.sectionTitle,
    required this.units,
  });

  factory LearningPathResponse.fromJson(Map<String, dynamic> json) {
    return LearningPathResponse(
      sectionId: json['section_id'] as String,
      sectionTitle: json['section_title'] as String,
      units: (json['units'] as List<dynamic>)
          .map((item) => PathUnit.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Path Unit Schema (for Learning Path)
class PathUnit {
  final String unitId;
  final String unitTitle;
  final int order;
  final List<PathLevel> levels;

  PathUnit({
    required this.unitId,
    required this.unitTitle,
    required this.order,
    required this.levels,
  });

  factory PathUnit.fromJson(Map<String, dynamic> json) {
    return PathUnit(
      unitId: json['unit_id'] as String,
      unitTitle: json['unit_title'] as String,
      order: json['order'] as int,
      levels: (json['levels'] as List<dynamic>)
          .map((item) => PathLevel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
