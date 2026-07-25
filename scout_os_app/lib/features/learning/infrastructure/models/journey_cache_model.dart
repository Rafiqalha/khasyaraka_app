import '../../domain/entities/learning_entities.dart';

class JourneyCacheModel {
  final String id;
  final String title;
  final List<NodeCacheModel> nodes;

  JourneyCacheModel({
    required this.id,
    required this.title,
    required this.nodes,
  });

  factory JourneyCacheModel.fromEntity(Journey entity) {
    return JourneyCacheModel(
      id: entity.id,
      title: entity.title,
      nodes: entity.activities.map((n) => NodeCacheModel.fromEntity(n)).toList(),
    );
  }

  Journey toEntity() {
    return Journey(
      id: id,
      title: title,
      activities: nodes.map((n) => n.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'nodes': nodes.map((n) => n.toJson()).toList(),
    };
  }

  factory JourneyCacheModel.fromJson(Map<String, dynamic> json) {
    return JourneyCacheModel(
      id: json['id'],
      title: json['title'],
      nodes: (json['nodes'] as List).map((n) => NodeCacheModel.fromJson(n)).toList(),
    );
  }
}

class NodeCacheModel {
  final String id;
  final String type;
  final String title;
  final int estimatedSeconds;
  final bool isRequired;
  final String telemetryKey;

  NodeCacheModel({
    required this.id,
    required this.type,
    required this.title,
    required this.estimatedSeconds,
    required this.isRequired,
    required this.telemetryKey,
  });

  factory NodeCacheModel.fromEntity(JourneyNode entity) {
    return NodeCacheModel(
      id: entity.id,
      type: entity.type.name,
      title: entity.title,
      estimatedSeconds: entity.estimatedDuration.inSeconds,
      isRequired: entity.isRequired,
      telemetryKey: entity.telemetryKey,
    );
  }

  JourneyNode toEntity() {
    final nodeType = NodeType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NodeType.mission,
    );

    return JourneyNode(
      id: id,
      type: nodeType,
      title: title,
      estimatedDuration: Duration(seconds: estimatedSeconds),
      isRequired: isRequired,
      telemetryKey: telemetryKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'estimatedSeconds': estimatedSeconds,
      'isRequired': isRequired,
      'telemetryKey': telemetryKey,
    };
  }

  factory NodeCacheModel.fromJson(Map<String, dynamic> json) {
    return NodeCacheModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      estimatedSeconds: json['estimatedSeconds'],
      isRequired: json['isRequired'],
      telemetryKey: json['telemetryKey'],
    );
  }
}
