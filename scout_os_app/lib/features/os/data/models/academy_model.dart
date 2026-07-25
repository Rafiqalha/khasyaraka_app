class AcademyModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String colorTheme;

  AcademyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorTheme,
  });

  factory AcademyModel.fromJson(Map<String, dynamic> json) {
    return AcademyModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      colorTheme: json['color_theme'] ?? '',
    );
  }
}
