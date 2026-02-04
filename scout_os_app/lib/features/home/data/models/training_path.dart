class UnitModel {
  final int id;
  final String unitId; // Backend unit ID (e.g., "puk_u1")
  final String title;
  final String description;
  final String colorHex;
  final int orderIndex;
  final List<LessonNode> lessons;

  UnitModel({
    required this.id,
    required this.unitId,
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
  ///   "unit_title": "Sejarah dan Trivia Kepramukaan",
  ///   "order": 1,
  ///   "levels": [...]
  /// }
  /// ```
  factory UnitModel.fromBackendJson(Map<String, dynamic> json) {
    // Parse levels as lessons
    final levelsJson = json['levels'] as List<dynamic>? ?? [];
    final lessons = levelsJson
        .map((levelJson) => LessonNode.fromBackendJson(levelJson as Map<String, dynamic>))
        .toList();
    
    return UnitModel(
      id: json['order'] as int? ?? 0, // Use order as ID for now
      unitId: json['unit_id'] as String? ?? '', // Backend unit ID (e.g., "puk_u1")
      title: json['unit_title'] as String? ?? '',
      description: json['unit_title'] as String? ?? '', // Backend doesn't have description
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
    
    List<LessonNode> lessonsList = list.map((i) => LessonNode.fromJson(i)).toList();
    lessonsList.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    // Extract unitId from legacy format if available, or generate from id
    String unitId = json['unit_id'] as String? ?? '';
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
          }
        }
      }
    }
    
    return UnitModel(
      id: json['id'] ?? 0,
      unitId: unitId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      colorHex: json['color_hex'] ?? '8D6E63',
      orderIndex: json['order_index'] ?? 0,
      lessons: lessonsList,
    );
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
    final backendStatus = json['status'] as String? ?? 'locked';
    
    // Map backend status to frontend status
    // Backend: "locked" | "available" | "in_progress" | "completed"
    // Frontend: "locked" | "active" | "unlocked" | "completed"
    String status;
    switch (backendStatus) {
      case 'available':
        status = 'active'; // Available level = active/unlocked
        break;
      case 'in_progress':
        status = 'active'; // In progress = active
        break;
      case 'completed':
        status = 'completed';
        break;
      case 'locked':
      default:
        status = 'locked';
        break;
    }
    
    return LessonNode(
      id: levelNumber,
      pathId: 1, // Will be set by parent unit
      title: json['title'] as String? ?? 'Level $levelNumber',
      description: _getDescriptionForDifficulty(difficulty),
      iconName: _getIconForLevel(levelNumber),
      status: status,
      stars: 0, // Backend doesn't have stars yet
      orderIndex: levelNumber,
      levelId: json['level_id'] as String?,
    );
  }

  /// Get icon based on level number
  static String _getIconForLevel(int levelNumber) {
    const icons = ['square', 'grass', 'radio', 'signal', 'school', 'link', 'anchor', 'history'];
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
      status: json['status'] ?? 'locked',
      stars: json['stars'] ?? 0,
      orderIndex: json['order_index'] ?? 0,
      levelId: json['level_id'] as String?,
    );
  }
}