import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/journey_node.dart';
import '../../../../core/telemetry/telemetry.dart';

// Dummy linear journey for G1.5 Validation with the new priorities
final _g15Nodes = [
  const JourneyNode(
    id: 'n1', 
    type: NodeType.preAssessment, 
    title: 'Pre-Assessment',
    estimatedDuration: Duration(minutes: 2),
    isRequired: true,
    telemetryKey: 'g15_pre_assessment',
  ),
  const JourneyNode(
    id: 'n2', 
    type: NodeType.journeyMap, 
    title: 'Journey Map',
    estimatedDuration: Duration(minutes: 1),
    isRequired: true,
    telemetryKey: 'g15_journey_map',
  ),
  const JourneyNode(
    id: 'n3', 
    type: NodeType.notebook, 
    title: 'What is an Array?',
    estimatedDuration: Duration(minutes: 3),
    isRequired: true,
    telemetryKey: 'g15_notebook_array_intro',
  ),
  const JourneyNode(
    id: 'n4', 
    type: NodeType.mission, 
    title: 'Mission: Fix Off-by-One',
    estimatedDuration: Duration(minutes: 6),
    isRequired: true,
    telemetryKey: 'g15_mission_array_oob',
  ),
  const JourneyNode(
    id: 'n5', 
    type: NodeType.thinking, 
    title: 'Analyzing Result',
    estimatedDuration: Duration(seconds: 5),
    isRequired: true,
    telemetryKey: 'g15_thinking_array_oob',
  ),
  const JourneyNode(
    id: 'n6', 
    type: NodeType.quickCheck, 
    title: 'Quick Check: Array Indexing',
    estimatedDuration: Duration(minutes: 1),
    isRequired: true,
    telemetryKey: 'g15_qc_array_index',
  ),
  const JourneyNode(
    id: 'n7', 
    type: NodeType.sandbox, 
    title: 'Sandbox: Array Playground',
    estimatedDuration: Duration(minutes: 5),
    isRequired: false,
    telemetryKey: 'g15_sandbox_array',
  ),
];

class JourneyState {
  final List<JourneyNode> nodes;
  final int currentIndex;
  
  JourneyNode get currentNode => nodes[currentIndex];
  bool get hasNext => currentIndex < nodes.length - 1;

  const JourneyState({
    required this.nodes,
    required this.currentIndex,
  });

  JourneyState copyWith({
    List<JourneyNode>? nodes,
    int? currentIndex,
  }) {
    return JourneyState(
      nodes: nodes ?? this.nodes,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class JourneyNotifier extends StateNotifier<JourneyState> {
  JourneyNotifier() : super(const JourneyState(
    nodes: [],
    currentIndex: 0,
  )) {
    // Initialize with data
    state = JourneyState(nodes: _g15Nodes, currentIndex: 0);
    _emitNodeEntered(state.currentNode);
  }

  void nextNode() {
    if (state.hasNext) {
      final oldNode = state.currentNode;
      
      Telemetry.track(
        event: JourneyEvent.nodeExited,
        metadata: {'nodeId': oldNode.id, 'telemetryKey': oldNode.telemetryKey},
      );
      
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      
      _emitNodeEntered(state.currentNode);
    } else {
      Telemetry.track(
        event: JourneyEvent.journeyCompleted,
      );
    }
  }
  
  void _emitNodeEntered(JourneyNode node) {
    Telemetry.track(
      event: JourneyEvent.nodeEntered,
      metadata: {'nodeId': node.id, 'telemetryKey': node.telemetryKey},
    );
  }
}

final journeyProvider = StateNotifierProvider<JourneyNotifier, JourneyState>((ref) {
  return JourneyNotifier();
});
