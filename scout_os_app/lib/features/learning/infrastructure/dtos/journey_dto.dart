class JourneyDto {
  final String id;
  final String title;
  final List<JourneyNodeDto> nodes;

  JourneyDto({required this.id, required this.title, required this.nodes});

  factory JourneyDto.fromJson(Map<String, dynamic> json) {
    return JourneyDto(
      id: json['id'] as String,
      title: json['title'] as String,
      nodes: (json['nodes'] as List).map((e) => JourneyNodeDto.fromJson(e)).toList(),
    );
  }
}

class JourneyNodeDto {
  final String id;
  final String type;
  final String title;
  final int estimatedSeconds;
  final bool isRequired;
  final String telemetryKey;

  JourneyNodeDto({
    required this.id,
    required this.type,
    required this.title,
    required this.estimatedSeconds,
    required this.isRequired,
    required this.telemetryKey,
  });

  factory JourneyNodeDto.fromJson(Map<String, dynamic> json) {
    return JourneyNodeDto(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      estimatedSeconds: json['estimatedSeconds'] as int,
      isRequired: json['isRequired'] as bool,
      telemetryKey: json['telemetryKey'] as String,
    );
  }
}
