/// Training Question Model
///
/// 1:1 mapping with backend TrainingQuestionResponse schema.
/// DO NOT modify field names or types - must match backend exactly.
///
/// IMPORTANT: payload structure depends on question type.
/// Frontend must switch by type, not assume structure.
class TrainingQuestion {
  final String id;
  final String levelId;
  final String
  type; // "multiple_choice" | "matching" | "true_false" | "input" | "ordering"
  final String question;
  final Map<String, dynamic> payload; // Type-specific structure
  final int xp;
  final int order;
  final bool isActive;
  final DateTime createdAt;

  TrainingQuestion({
    required this.id,
    required this.levelId,
    required this.type,
    required this.question,
    required this.payload,
    required this.xp,
    required this.order,
    required this.isActive,
    required this.createdAt,
  });

  /// Parse from backend API response
  /// Matches: GET /training/levels/{id}/questions
  factory TrainingQuestion.fromJson(Map<String, dynamic> json) {
    // Defensive type casting: handle both int and String for IDs
    String safeStringId(String key) {
      final value = json[key];
      if (value is int) return value.toString();
      if (value is String) return value;
      return '';
    }

    // Defensive type casting for numeric fields
    int safeInt(String key, int defaultValue) {
      final value = json[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    return TrainingQuestion(
      id: safeStringId('id'),
      levelId: safeStringId('level_id'),
      type: json['type']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      xp: safeInt('xp', 2),
      order: safeInt('order', 1),
      isActive: json['is_active'] == true || json['isActive'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_id': levelId,
      'type': type,
      'question': question,
      'payload': payload,
      'xp': xp,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ==================== TYPE-SPECIFIC PAYLOAD HELPERS ====================
  // These helpers make it easier to access payload data, but payload
  // structure MUST match backend schema exactly.

  /// For multiple_choice: Get options list
  List<String>? getMultipleChoiceOptions() {
    if (type != 'multiple_choice') return null;
    final options = payload['options'] as List<dynamic>?;
    return options?.map((e) => e.toString()).toList();
  }

  /// For matching: Get left and right items
  Map<String, List<String>>? getMatchingItems() {
    if (type != 'matching') return null;
    // Backend payload uses `pairs: [{left: ..., right: ...}, ...]`.
    // Keep backward compatibility with any older payload shapes.
    final pairs = payload['pairs'];
    if (pairs is List) {
      final left = <String>[];
      final right = <String>[];
      for (final item in pairs) {
        if (item is Map) {
          final l = item['left']?.toString();
          final r = item['right']?.toString();
          if (l != null) left.add(l);
          if (r != null) right.add(r);
        }
      }
      return {'left': left, 'right': right};
    }

    // Fallback: older shape (left_items/right_items)
    return {
      'left':
          (payload['left_items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      'right':
          (payload['right_items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    };
  }

  /// For true_false: Get statement
  String? getTrueFalseStatement() {
    if (type != 'true_false') return null;
    return payload['statement'] as String?;
  }

  /// For input: Get placeholder
  String? getInputPlaceholder() {
    if (type != 'input') return null;
    return payload['placeholder'] as String?;
  }

  /// For ordering: Get items to order
  List<String>? getOrderingItems() {
    if (type != 'ordering') return null;
    final items = payload['items'] as List<dynamic>?;
    return items?.map((e) => e.toString()).toList();
  }
}

/// Question List Response
/// Matches: GET /training/levels/{id}/questions response
class QuestionListResponse {
  final int total;
  final String levelId;
  final List<TrainingQuestion> questions;

  QuestionListResponse({
    required this.total,
    required this.levelId,
    required this.questions,
  });

  factory QuestionListResponse.fromJson(Map<String, dynamic> json) {
    // Defensive type casting
    String safeStringId(String key) {
      final value = json[key];
      if (value is int) return value.toString();
      if (value is String) return value;
      return '';
    }

    int safeInt(String key, int defaultValue) {
      final value = json[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    return QuestionListResponse(
      total: safeInt('total', 0),
      levelId: safeStringId('level_id'),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (item) =>
                    TrainingQuestion.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
