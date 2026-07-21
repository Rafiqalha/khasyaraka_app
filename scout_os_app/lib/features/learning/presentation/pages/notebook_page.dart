import 'package:flutter/material.dart';
import '../../../../design_system/components/notebook_block.dart';
import '../../../../core/telemetry/telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotebookPage extends ConsumerStatefulWidget {
  final String nodeId;
  const NotebookPage({super.key, required this.nodeId});

  @override
  ConsumerState<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends ConsumerState<NotebookPage> {
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    // Simulate interaction timer check
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && !_hasInteracted) {
        Telemetry.track(
          event: JourneyEvent.hintOpened, // Using as proxy for "passive alert"
          metadata: {'nodeId': widget.nodeId, 'reason': 'no_interaction_30s'},
        );
      }
    });
  }

  void _handleMicroInteraction() {
    setState(() {
      _hasInteracted = true;
    });
    Telemetry.track(
      event: JourneyEvent.continuePressed, // Or a specific micro_interaction event
      metadata: {'nodeId': widget.nodeId, 'action': 'micro_interaction_clicked'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: NotebookBlock(
            title: "What is an Array?",
            explanation: "An array is a linear collection of elements, accessed via indices. The most common pitfall is the 'Off-by-One' error.",
            visual: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey.withAlpha(20),
              child: const Center(child: Text("Interactive Array Memory Visualizer")),
            ),
            microQuestion: "Click here to reveal the code snippet below.",
            codeSnippet: _hasInteracted ? "arr = [1, 2, 3]\nprint(arr[0])" : null,
            onContinue: _handleMicroInteraction,
            continueText: _hasInteracted ? "Done" : "Reveal Code",
          ),
        ),
      ),
    );
  }
}
