class IncidentModel {
  final String id;
  final String levelId;
  final String type;
  final String question;
  final Map<String, dynamic> payload;
  final int xp;
  final int order;
  final String source;
  final int difficultyLevel;
  final String sourceUrl;
  final String generatedAt;

  IncidentModel({
    required this.id,
    required this.levelId,
    required this.type,
    required this.question,
    required this.payload,
    required this.xp,
    required this.order,
    required this.source,
    required this.difficultyLevel,
    required this.sourceUrl,
    required this.generatedAt,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    String safeString(String key) {
      final v = json[key];
      if (v == null) return '';
      return v.toString();
    }

    int safeInt(String key, int def) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return def;
    }

    return IncidentModel(
      id: safeString('id'),
      levelId: safeString('level_id'),
      type: safeString('type'),
      question: safeString('question'),
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      xp: safeInt('xp', 5),
      order: safeInt('ord', 1),
      source: safeString('source'),
      difficultyLevel: safeInt('difficulty_level', 5),
      sourceUrl: safeString('source_url'),
      generatedAt: safeString('generated_at'),
    );
  }

  String get sourceLabel {
    if (source.contains('hackernews')) return 'TheHackersNews';
    if (source.contains('bleeping')) return 'BleepingComputer';
    return source;
  }

  String get toolLabel {
    switch (type) {
      case 'cipher_rotor':
        return 'Cipher Rotor';
      case 'packet_sweeper':
        return 'Packet Sweeper';
      case 'vuln_spotter':
        return 'Vuln Spotter';
      case 'network_cutter':
        return 'Network Cutter';
      case 'log_anomaly':
        return 'Log Anomaly';
      default:
        return type;
    }
  }
}
