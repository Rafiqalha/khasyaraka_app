class SkuOverviewModel {
  final double bantaraProgress;
  final bool isLaksanaUnlocked;

  SkuOverviewModel({
    required this.bantaraProgress,
    required this.isLaksanaUnlocked,
  });

  factory SkuOverviewModel.fromJson(Map<String, dynamic> json) {
    return SkuOverviewModel(
      bantaraProgress: (json['bantara_progress'] as num?)?.toDouble() ?? 0,
      isLaksanaUnlocked: json['is_laksana_unlocked'] as bool? ?? false,
    );
  }
}

class SkuPointStatusModel {
  final String id;
  final int number;
  final String title;
  final String category;
  final bool isCompleted;
  final int score;

  SkuPointStatusModel({
    required this.id,
    required this.number,
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.score,
  });

  factory SkuPointStatusModel.fromJson(Map<String, dynamic> json) {
    return SkuPointStatusModel(
      id: json['id'] as String,
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
    );
  }
}

class SkuPointDetailModel {
  final String id;
  final String level;
  final int number;
  final String title;
  final String description;
  final String category;
  final List<SkuQuestionModel> questions;
  final String? officialRef;
  final bool isCompleted;
  final int score;

  SkuPointDetailModel({
    required this.id,
    required this.level,
    required this.number,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    required this.officialRef,
    required this.isCompleted,
    required this.score,
  });

  factory SkuPointDetailModel.fromJson(Map<String, dynamic> json) {
    final content = json['quiz_content'] as Map<String, dynamic>? ?? {};
    final questions = (content['questions'] as List<dynamic>? ?? [])
        .map((q) => SkuQuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();

    return SkuPointDetailModel(
      id: json['id'] as String,
      level: json['level'] as String? ?? 'bantara',
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      questions: questions,
      officialRef: content['official_ref'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
    );
  }
}

class SkuQuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;

  SkuQuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory SkuQuestionModel.fromJson(Map<String, dynamic> json) {
    return SkuQuestionModel(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      correctIndex: json['correct_index'] as int? ?? 0,
    );
  }
}

class SkuSubmitResultModel {
  final String skuPointId;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final bool isCompleted;

  SkuSubmitResultModel({
    required this.skuPointId,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.isCompleted,
  });

  factory SkuSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return SkuSubmitResultModel(
      skuPointId: json['sku_point_id'] as String,
      score: json['score'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}