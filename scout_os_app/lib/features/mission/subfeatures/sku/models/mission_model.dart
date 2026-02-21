class MissionModel {
  final int id;
  final String title;
  final String levelCategory;
  final String badgeUrl;
  final bool isPremium;

  MissionModel({
    required this.id,
    required this.title,
    required this.levelCategory,
    required this.badgeUrl,
    required this.isPremium,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'],
      title: json['mission_title'],
      levelCategory: json['level_category'] ?? 'Purwa',
      badgeUrl: json['badge_image_url'] ?? '',
      isPremium: json['is_premium'] ?? false,
    );
  }
}
