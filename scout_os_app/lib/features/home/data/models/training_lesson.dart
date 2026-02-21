class TrainingLesson {
  final String id;
  final String pathId;
  final String title;
  final int xpReward;
  final int orderIndex;

  /// UI STATE
  final String status; // locked | active | completed

  const TrainingLesson({
    required this.id,
    required this.pathId,
    required this.title,
    required this.xpReward,
    required this.orderIndex,
    required this.status,
  });

  TrainingLesson copyWith({String? status}) {
    return TrainingLesson(
      id: id,
      pathId: pathId,
      title: title,
      xpReward: xpReward,
      orderIndex: orderIndex,
      status: status ?? this.status,
    );
  }

  factory TrainingLesson.fromJson(Map<String, dynamic> json) {
    return TrainingLesson(
      id: json['id'],
      pathId: json['path_id'],
      title: json['title'],
      xpReward: json['xp_reward'] ?? 10,
      orderIndex: json['order_index'] ?? 0,
      status: json['status'] ?? 'locked',
    );
  }
}
