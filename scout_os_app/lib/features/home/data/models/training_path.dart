class UnitModel {
  final int id;
  final String unitId; // Backend unit ID (e.g., "puk_u1")
  final String sectionId; // Backend section ID (e.g., "puk", "ppgd")
  final String title;
  final String description;
  final String colorHex;
  final int orderIndex;
  final List<LessonNode> lessons;

  UnitModel({
    required this.id,
    required this.unitId,
    required this.sectionId,
    required this.title,
    required this.description,
    required this.colorHex,
    required this.orderIndex,
    required this.lessons,
  });

  /// Parse from backend API response
  ///
  /// Backend structure from /api/v1/training/sections/{id}/path:
  /// ```json
  /// {
  ///   "unit_id": "puk_unit_1",
  ///   "section_id": "puk",
  ///   "unit_title": "Sejarah dan Trivia Kepramukaan",
  ///   "order": 1,
  ///   "levels": [...]
  /// }
  /// ```
  factory UnitModel.fromBackendJson(Map<String, dynamic> json) {
    // Parse levels as lessons
    final levelsJson = json['levels'] as List<dynamic>? ?? [];
    final lessons = levelsJson
        .map(
          (levelJson) =>
              LessonNode.fromBackendJson(levelJson as Map<String, dynamic>),
        )
        .toList();

    // Extract section_id from json or from unit_id (e.g., "puk_u1" -> "puk")
    String sectionId = json['section_id'] as String? ?? '';
    if (sectionId.isEmpty) {
      final unitId = json['unit_id'] as String? ?? '';
      if (unitId.contains('_')) {
        sectionId = unitId.split('_').first;
      }
    }

    return UnitModel(
      id: json['order'] as int? ?? 0,
      unitId: json['unit_id'] as String? ?? '',
      sectionId: sectionId,
      title: json['unit_title'] as String? ?? '',
      description: json['unit_title'] as String? ?? '',
      colorHex: _getColorForUnit(json['order'] as int? ?? 1),
      orderIndex: json['order'] as int? ?? 0,
      lessons: lessons,
    );
  }

  /// Get color hex based on unit order
  static String _getColorForUnit(int order) {
    const colors = [
      'FF6B35', // Orange
      '4ECDC4', // Teal
      '95E1D3', // Light Teal
      'F7B731', // Yellow
      'FC5C65', // Red
    ];
    return colors[(order - 1) % colors.length];
  }

  /// Parse from local database (Supabase legacy format)
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['khasyaraka_training_lessons'] ?? json['lessons'];
    var list = rawList as List? ?? [];

    List<LessonNode> lessonsList = list
        .map((i) => LessonNode.fromJson(i))
        .toList();
    lessonsList.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    // Extract unitId from legacy format if available, or generate from id
    String unitId = json['unit_id'] as String? ?? '';
    String sectionId = json['section_id'] as String? ?? '';

    if (unitId.isEmpty && json['id'] != null) {
      // Try to extract from lessons if available
      final lessons = (json['lessons'] as List<dynamic>? ?? []);
      if (lessons.isNotEmpty) {
        final firstLesson = lessons.first as Map<String, dynamic>?;
        final levelId = firstLesson?['level_id'] as String? ?? '';
        // Extract unit ID from level ID (e.g., "puk_u1_l1" -> "puk_u1")
        if (levelId.isNotEmpty) {
          final parts = levelId.split('_');
          if (parts.length >= 2) {
            unitId = '${parts[0]}_${parts[1]}';
            sectionId = parts[0]; // Extract section from level ID
          }
        }
      }
    }

    // Fallback: extract section from unitId
    if (sectionId.isEmpty && unitId.contains('_')) {
      sectionId = unitId.split('_').first;
    }

    return UnitModel(
      id: json['id'] ?? 0,
      unitId: unitId,
      sectionId: sectionId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      colorHex: json['color_hex'] ?? '8D6E63',
      orderIndex: json['order_index'] ?? 0,
      lessons: lessonsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'section_id': sectionId,
      'title': title,
      'description': description,
      'color_hex': colorHex,
      'order_index': orderIndex,
      'lessons': lessons.map((e) => e.toJson()).toList(),
    };
  }
}

class LessonNode {
  final int id;
  final int pathId;
  final String title;
  final String description;
  final String iconName;
  final String status; // 'locked', 'active', 'completed'
  final int stars;
  final int orderIndex;
  final String? levelId; // Backend level ID (e.g., "puk_u1_l1")

  LessonNode({
    required this.id,
    required this.pathId,
    required this.title,
    required this.description,
    required this.iconName,
    required this.status,
    required this.stars,
    required this.orderIndex,
    this.levelId,
  });

  /// Parse from backend API response
  ///
  /// Backend structure from /api/v1/training/sections/{id}/path:
  /// ```json
  /// {
  ///   "level_id": "puk_u1_l1",
  ///   "title": "Level 1",
  ///   "level_number": 1,
  ///   "difficulty": "very_easy",
  ///   "xp_reward": 10,
  ///   "status": "unlocked"
  /// }
  /// ```
  factory LessonNode.fromBackendJson(Map<String, dynamic> json) {
    final levelNumber = json['level_number'] as int? ?? 1;
    final difficulty = json['difficulty'] as String? ?? 'easy';
    final backendStatus = json['status'] as String? ?? 'LOCKED';

    // Map backend status to frontend status
    // Backend: "LOCKED" | "UNLOCKED" | "COMPLETED"
    // Frontend: "LOCKED" | "UNLOCKED" | "COMPLETED"
    String status;
    final normalizedStatus = backendStatus.toUpperCase();

    switch (normalizedStatus) {
      case 'UNLOCKED':
      case 'AVAILABLE': // Legacy support
      case 'IN_PROGRESS': // Legacy/Alt support
        status = 'UNLOCKED';
        break;
      case 'COMPLETED':
        status = 'COMPLETED';
        break;
      case 'LOCKED':
      default:
        status = 'LOCKED';
        break;
    }

    return LessonNode(
      id: levelNumber,
      pathId: 1, // Will be set by parent unit
      title: json['title'] as String? ?? 'Level $levelNumber',
      description: _getDescriptionForDifficulty(difficulty),
      iconName: _getIconForLevel(levelNumber),
      status: status, // Now strictly UPPERCASE
      stars: 0, // Backend doesn't have stars yet
      orderIndex: levelNumber,
      levelId: json['level_id'] as String?,
    );
  }

  /// Get icon based on level number
  static String _getIconForLevel(int levelNumber) {
    const icons = [
      'square',
      'grass',
      'radio',
      'signal',
      'school',
      'link',
      'anchor',
      'history',
    ];
    return icons[(levelNumber - 1) % icons.length];
  }

  /// Get description based on difficulty
  static String _getDescriptionForDifficulty(String difficulty) {
    const descriptions = {
      'very_easy': 'Sangat mudah - Cocok untuk pemula',
      'easy': 'Mudah - Tingkat dasar',
      'medium': 'Sedang - Perlu fokus',
      'hard': 'Sulit - Tantangan tinggi',
    };
    return descriptions[difficulty] ?? 'Level training';
  }

  /// Parse from local database (Supabase legacy format)
  factory LessonNode.fromJson(Map<String, dynamic> json) {
    return LessonNode(
      id: json['id'] ?? 0,
      pathId: json['path_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'star',
      status: json['status'] ?? 'LOCKED',
      stars: json['stars'] ?? 0,
      orderIndex: json['order_index'] ?? 0,
      levelId: json['level_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path_id': pathId,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'status': status,
      'stars': stars,
      'order_index': orderIndex,
      'level_id': levelId,
    };
  }
}
