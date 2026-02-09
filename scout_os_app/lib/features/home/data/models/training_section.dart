import 'training_path.dart';

/// Training Section Model
/// 
/// 1:1 mapping with backend TrainingSectionResponse schema.
/// DO NOT modify field names or types - must match backend exactly.
class TrainingSection {
  final String id;
  final String title;
  final String? description;
  final String tier; // "free" | "premium"
  final int order;
  final bool isActive;
  final DateTime createdAt;

  TrainingSection({
    required this.id,
    required this.title,
    this.description,
    required this.tier,
    required this.order,
    required this.isActive,
    required this.createdAt,
  });

  /// Parse from backend API response
  /// Matches: GET /training/sections
  factory TrainingSection.fromJson(Map<String, dynamic> json) {
    return TrainingSection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tier: json['tier'] as String? ?? 'free',
      order: json['order'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tier': tier,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Section List Response
/// Matches: GET /training/sections response
class SectionListResponse {
  final int total;
  final List<TrainingSection> sections;

  SectionListResponse({
    required this.total,
    required this.sections,
  });

  factory SectionListResponse.fromJson(Map<String, dynamic> json) {
    return SectionListResponse(
      total: json['total'] as int,
      sections: (json['sections'] as List<dynamic>)
          .map((item) => TrainingSection.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }
}

/// Section with Units - for UI rendering
/// Combines section metadata with its units
class SectionWithUnits {
  final TrainingSection section;
  final List<UnitModel> units;

  SectionWithUnits({
    required this.section,
    required this.units,
  });

  String get id => section.id;
  String get title => section.title;
  int get order => section.order;
}
