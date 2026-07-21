import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/journey_node.dart';

// Dummy linear journey for G1.5 Validation
final _g15Nodes = [
  const JourneyNode(id: 'n1', type: NodeType.preAssessment, title: 'Pre-Assessment'),
  const JourneyNode(id: 'n2', type: NodeType.journeyMap, title: 'Journey Map'),
  // We will add Notebook and others in later batches
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
  JourneyNotifier() : super(JourneyState(
    nodes: _g15Nodes,
    currentIndex: 0,
  ));

  void nextNode() {
    if (state.hasNext) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }
}

final journeyProvider = StateNotifierProvider<JourneyNotifier, JourneyState>((ref) {
  return JourneyNotifier();
});
