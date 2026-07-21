import 'package:flutter/material.dart';
import 'components/competency_bar.dart';
import 'components/journey_card.dart';
import 'components/mission_console.dart';
import 'components/notebook_block.dart';
import 'components/thinking_screen.dart';
import 'spacing.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pradigi Component Preview')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: PradigiSpacing.desktopMaxWidth),
            child: Padding(
              padding: const EdgeInsets.all(PradigiSpacing.mobileContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  const _SectionHeader("1. Notebook Block"),
                  NotebookBlock(
                    title: "What is an Array?",
                    explanation: "An array is a data structure consisting of a collection of elements, each identified by at least one array index or key.",
                    microQuestion: "If you have 5 boxes, what is the index of the last box if we start counting from 0?",
                    codeSnippet: "numbers = [10, 20, 30, 40, 50]\nprint(numbers[4]) # Output: 50",
                    onContinue: () {},
                  ),
                  
                  const _Divider(),
                  const _SectionHeader("2. Journey Card"),
                  JourneyCard(
                    title: "Arrays",
                    estimatedTime: "12 menit",
                    nodes: const [
                      JourneyNodeItem(title: "Notebook", status: JourneyNodeStatus.completed),
                      JourneyNodeItem(title: "Quick Check", status: JourneyNodeStatus.active),
                      JourneyNodeItem(title: "Mission", status: JourneyNodeStatus.locked),
                    ],
                    onContinue: () {},
                  ),
                  
                  const _Divider(),
                  const _SectionHeader("3. Mission Console"),
                  MissionConsole(
                    missionTitle: "Fix Off-by-One Error",
                    objective: "The function sum_list() is missing the last element in the calculation. Fix the loop boundary.",
                    estimatedTime: "6 min",
                    difficulty: "Easy",
                    concept: "Iteration",
                    editorWidget: const Center(child: Text("Editor Component Placeholder", style: TextStyle(color: Colors.white))),
                    status: MissionConsoleStatus.failed,
                    expectedOutput: "10",
                    receivedOutput: "8",
                    errorReason: "IndexError: list index out of range at line 4",
                    onRunTests: () {},
                    onHintRequested: () {},
                  ),

                  const _Divider(),
                  const _SectionHeader("4. Competency Bar"),
                  const CompetencyBar(
                    title: "Iteration",
                    subtitle: "Mastery over loops and sequences",
                    oldPercentage: 0.45,
                    newPercentage: 0.63,
                    animateDelta: true,
                  ),

                  const _Divider(),
                  const _SectionHeader("5. Thinking Screen"),
                  const ThinkingScreen(
                    checkItems: [
                      ThinkingCheckItem(label: "Code Quality", status: ThinkingCheckItemStatus.completed),
                      ThinkingCheckItem(label: "Reasoning Pattern", status: ThinkingCheckItemStatus.analyzing),
                      ThinkingCheckItem(label: "Runtime Result", status: ThinkingCheckItemStatus.pending),
                      ThinkingCheckItem(label: "Evidence Generated", status: ThinkingCheckItemStatus.pending),
                    ],
                    statusMessage: "Updating competency...",
                  ),
                  
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PradigiSpacing.s24),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: PradigiSpacing.s48),
      child: Divider(),
    );
  }
}
