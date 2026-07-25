class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String source;
  final DateTime detectedAt;
  final Map<String, dynamic>? intelligenceData;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.detectedAt,
    this.intelligenceData,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      source: json['source'] as String,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      intelligenceData: json['intelligence_data'] as Map<String, dynamic>?,
    );
  }
}
