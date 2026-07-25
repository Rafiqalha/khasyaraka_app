import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import '../controllers/workspace_controller.dart';

class WorkspaceAnalysisPanel extends ConsumerWidget {
  const WorkspaceAnalysisPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceData = ref.watch(workspaceProvider);

    if (workspaceData.state != WorkspaceState.completed && workspaceData.state != WorkspaceState.failed) {
      return const SizedBox.shrink();
    }

    final isPassed = workspaceData.isPassed ?? false;
    final color = isPassed ? const Color(0xFF3FB950) : const Color(0xFFF85149);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color.withOpacity(0.5))),
              color: color.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  isPassed ? Icons.check_circle_outline : Icons.error_outline,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPassed ? 'Pradigi Evaluation: Passed' : 'Pradigi Analysis',
                    style: PradigiTypography.body.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  workspaceData.analysisFeedback ?? 'No analysis provided.',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 14,
                    color: Color(0xFFC9D1D9),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
