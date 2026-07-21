import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/components/mission_console.dart';
import '../../../../core/telemetry/telemetry.dart';

enum MissionState { idle, editing, running, passed, failed, analyzing, completed }

class MissionPage extends ConsumerStatefulWidget {
  final String nodeId;
  const MissionPage({super.key, required this.nodeId});

  @override
  ConsumerState<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends ConsumerState<MissionPage> {
  MissionState _state = MissionState.idle;

  void _runTests() async {
    setState(() {
      _state = MissionState.running;
    });
    
    Telemetry.track(
      event: JourneyEvent.missionRun,
      metadata: {'nodeId': widget.nodeId},
    );

    // Simulate backend test execution
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success
    setState(() {
      _state = MissionState.passed;
    });
    
    Telemetry.track(
      event: JourneyEvent.missionPassed,
      metadata: {'nodeId': widget.nodeId},
    );
  }

  void _continueToAnalysis() {
    // This transitions to "Analyzing" locally or signals the JourneyController to move to the Thinking Screen node.
    // As per user request, MissionPage should have "Analyzing -> Completed" state, but the user also wants a dedicated Thinking Screen.
    // The flow: Mission Passed -> Hit Continue -> Transition to next node (Thinking Screen).
    // Let's just track continuePressed and let the shell handle the actual node switch.
    Telemetry.track(
      event: JourneyEvent.continuePressed,
      metadata: {'nodeId': widget.nodeId, 'action': 'continue_from_mission'},
    );
    // The LearningShell's Bottom CTA actually controls the global nextNode(), so the Mission component's continue button can trigger it if we pass a callback, or we hide the shell's CTA and use this one.
    // For now, we update local state.
    setState(() {
      _state = MissionState.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    MissionConsoleStatus consoleStatus;
    switch (_state) {
      case MissionState.idle:
      case MissionState.editing:
        consoleStatus = MissionConsoleStatus.idle;
        break;
      case MissionState.running:
        consoleStatus = MissionConsoleStatus.running;
        break;
      case MissionState.passed:
      case MissionState.analyzing:
      case MissionState.completed:
        consoleStatus = MissionConsoleStatus.passed;
        break;
      case MissionState.failed:
        consoleStatus = MissionConsoleStatus.failed;
        break;
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: MissionConsole(
            missionTitle: "Fix Off-by-One Error",
            objective: "Fix the loop boundary so the last element is included.",
            estimatedTime: "6 min",
            difficulty: "Easy",
            concept: "Iteration",
            editorWidget: GestureDetector(
              onTap: () {
                if (_state == MissionState.idle) {
                  setState(() => _state = MissionState.editing);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Text(
                  "def sum_list(numbers):\n    total = 0\n    for i in range(len(numbers) - 1):\n        total += numbers[i]\n    return total",
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                ),
              ),
            ),
            status: consoleStatus,
            onRunTests: _runTests,
            onContinue: _state == MissionState.passed ? _continueToAnalysis : null,
          ),
        ),
      ),
    );
  }
}
