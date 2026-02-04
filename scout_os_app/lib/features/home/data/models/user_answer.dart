class UserAnswer {
  final String id; // UUID
  final String userId;
  final String questionId;
  final String answer;
  final bool isCorrect;

  UserAnswer({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.answer,
    required this.isCorrect,
  });

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    // Defensive type casting: handle both int and String for IDs
    String safeId(String key) {
      final value = json[key];
      if (value is int) return value.toString();
      if (value is String) return value;
      return '';
    }

    return UserAnswer(
      id: safeId('id'),
      userId: safeId('user_id'),
      questionId: safeId('question_id'),
      answer: json['answer']?.toString() ?? '',
      isCorrect: json['is_correct'] == true || json['isCorrect'] == true,
    );
  }
}
