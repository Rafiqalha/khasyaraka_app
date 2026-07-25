import 'package:flutter/material.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/tokens/spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/components/mission_console.dart';
import '../controllers/mission_controller.dart';
import '../../../../core/di/providers.dart';

class MissionPage extends ConsumerWidget {
  final String nodeId;
  const MissionPage({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionProvider);
    final notifier = ref.read(missionProvider.notifier);

    // Listen to mission completion
    ref.listen<MissionState>(missionProvider, (previous, next) {
      if (next == MissionState.passed) {
        ref.read(journeyProvider.notifier).completeNode();
      }
    });

    MissionConsoleStatus consoleStatus;
    switch (state) {
      case MissionState.idle:
      case MissionState.editing:
        consoleStatus = MissionConsoleStatus.idle;
        break;
      case MissionState.running:
        consoleStatus = MissionConsoleStatus.running;
        break;
      case MissionState.passed:
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
                ref.read(missionProvider.notifier).editCode();
              },
              child: Container(
                padding: const EdgeInsets.all(PradigiSpacing.s16),
                color: PradigiColors.textPrimary,
                child: Text(
                  "def sum_list(numbers):\n    total = 0\n    for i in range(len(numbers) - 1):\n        total += numbers[i]\n    return total",
                  style: PradigiTypography.code.copyWith(color: PradigiColors.surface),
                ),
              ),
            ),
            status: consoleStatus,
            onRunTests: () => notifier.runTests("mock_code"),
            onContinue: notifier.complete,
          ),
        ),
      ),
    );
  }
}
