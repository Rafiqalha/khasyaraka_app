/// Training Unit Model
/// 
/// 1:1 mapping with backend TrainingUnitResponse schema.
/// DO NOT modify field names or types - must match backend exactly.
class TrainingUnit {
  final String id;
  final String sectionId;
  final String title;
  final String? description;
  final int order;
  final int totalLevels;
  final bool isActive;
  final DateTime createdAt;

  TrainingUnit({
    required this.id,
    required this.sectionId,
    required this.title,
    this.description,
    required this.order,
    required this.totalLevels,
    required this.isActive,
    required this.createdAt,
  });

  /// Parse from backend API response
  /// Matches: GET /training/sections/{id}/units
  factory TrainingUnit.fromJson(Map<String, dynamic> json) {
    return TrainingUnit(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      order: json['order'] as int? ?? 1,
      totalLevels: json['total_levels'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'title': title,
      'description': description,
      'order': order,
      'total_levels': totalLevels,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Unit List Response
/// Matches: GET /training/sections/{id}/units response
class UnitListResponse {
  final int total;
  final String sectionId;
  final List<TrainingUnit> units;

  UnitListResponse({
    required this.total,
    required this.sectionId,
    required this.units,
  });

  factory UnitListResponse.fromJson(Map<String, dynamic> json) {
    return UnitListResponse(
      total: json['total'] as int,
      sectionId: json['section_id'] as String,
      units: (json['units'] as List<dynamic>)
          .map((item) => TrainingUnit.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
