class PublicProfileModel {
  final int id;
  final String? fullName;
  final String? pictureUrl;
  final int totalXp;
  final int streak;
  final String hackLevel;
  final List<String> tkkBadges;

  PublicProfileModel({
    required this.id,
    this.fullName,
    this.pictureUrl,
    this.totalXp = 0,
    this.streak = 0,
    this.hackLevel = 'Script Kiddie',
    this.tkkBadges = const [],
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicProfileModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String?,
      pictureUrl: json['picture_url'] as String?,
      totalXp: json['total_xp'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      hackLevel: json['hack_level'] as String? ?? 'Script Kiddie',
      tkkBadges:
          (json['tkk_badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
