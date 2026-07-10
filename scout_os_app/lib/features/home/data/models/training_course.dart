class TrainingCourse {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int ord;
  final bool isActive;

  TrainingCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.ord,
    required this.isActive,
  });

  factory TrainingCourse.fromJson(Map<String, dynamic> json) {
    return TrainingCourse(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'explore',
      ord: json['ord'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'ord': ord,
      'is_active': isActive,
    };
  }
}
