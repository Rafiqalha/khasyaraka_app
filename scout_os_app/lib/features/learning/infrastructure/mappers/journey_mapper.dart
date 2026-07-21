import '../../domain/entities/learning_entities.dart';
import '../dtos/journey_dto.dart';

class JourneyMapper {
  static Journey fromDto(JourneyDto dto) {
    return Journey(
      id: dto.id,
      title: dto.title,
      nodes: dto.nodes.map((n) => _mapNode(n)).toList(),
      isCompleted: false, // Default logic
    );
  }

  static JourneyNode _mapNode(JourneyNodeDto dto) {
    return JourneyNode(
      id: dto.id,
      type: _mapNodeType(dto.type),
      title: dto.title,
      estimatedDuration: Duration(seconds: dto.estimatedSeconds),
      isRequired: dto.isRequired,
      telemetryKey: dto.telemetryKey,
    );
  }

  static NodeType _mapNodeType(String typeString) {
    switch (typeString) {
      case 'PRE_ASSESSMENT': return NodeType.preAssessment;
      case 'JOURNEY_MAP': return NodeType.journeyMap;
      case 'NOTEBOOK': return NodeType.notebook;
      case 'QUICK_CHECK': return NodeType.quickCheck;
      case 'SANDBOX': return NodeType.sandbox;
      case 'MISSION': return NodeType.mission;
      case 'THINKING': return NodeType.thinking;
      case 'POST_ASSESSMENT': return NodeType.postAssessment;
      case 'LOOKING_BACK': return NodeType.lookingBack;
      case 'PASSPORT': return NodeType.passport;
      default: return NodeType.notebook; // Fallback
    }
  }
}
