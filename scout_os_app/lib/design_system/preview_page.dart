import 'package:flutter/material.dart';
import 'components/competency_bar.dart';
import 'components/journey_card.dart';
import 'components/mission_console.dart';
import 'components/notebook_block.dart';
import 'components/thinking_screen.dart';
import 'tokens/colors.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';
import 'tokens/radius.dart';

class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PradigiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: PradigiSpacing.desktopMaxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PradigiSpacing.mobileContentPadding,
                  vertical: PradigiSpacing.s48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Header (replaces AppBar)
                    const Text("Pradigi Design System", style: PradigiTypography.caption),
                    const SizedBox(height: PradigiSpacing.s8),
                    const Text("Component Preview", style: PradigiTypography.h1),
                    const SizedBox(height: PradigiSpacing.s4),
                    Text("Version 1.0", style: PradigiTypography.bodySecondary),
                    
                    const _WhitespaceSpacer(),
                    
                    // 1. Journey
                    const _SectionHeader("1. Journey Card"),
                    const _PreviewContainer(
                      child: JourneyCard(
                        title: "Arrays",
                        estimatedTime: "12 menit",
                        nodes: [
                          JourneyNodeItem(title: "Notebook", status: JourneyNodeStatus.completed),
                          JourneyNodeItem(title: "Quick Check", status: JourneyNodeStatus.active),
                          JourneyNodeItem(title: "Mission", status: JourneyNodeStatus.locked),
                        ],
                        onContinue: _dummyCallback,
                      ),
                    ),
                    
                    const _WhitespaceSpacer(),
                    
                    // 2. Notebook
                    const _SectionHeader("2. Notebook Block"),
                    const _PreviewContainer(
                      child: NotebookBlock(
                        title: "What is an Array?",
                        explanation: "An array is a data structure consisting of a collection of elements, each identified by at least one array index or key.",
                        microQuestion: "If you have 5 boxes, what is the index of the last box if we start counting from 0?",
                        codeSnippet: "numbers = [10, 20, 30, 40, 50]\nprint(numbers[4]) # Output: 50",
                        onContinue: _dummyCallback,
                      ),
                    ),
                    
                    const _WhitespaceSpacer(),
                    
                    // 3. Mission
                    const _SectionHeader("3. Mission Console"),
                    _PreviewContainer(
                      child: MissionConsole(
                        missionTitle: "Fix Off-by-One Error",
                        objective: "The function sum_list() is missing the last element in the calculation. Fix the loop boundary.",
                        estimatedTime: "6 min",
                        difficulty: "Easy",
                        concept: "Iteration",
                        editorWidget: Container(
                          padding: const EdgeInsets.all(PradigiSpacing.s16),
                          color: PradigiColors.textPrimary,
                          width: double.infinity,
                          child: Text(
                            "def sum_list(numbers):\n    total = 0\n    for i in range(len(numbers) - 1):\n        total += numbers[i]\n    return total", 
                            style: PradigiTypography.code.copyWith(color: PradigiColors.surface),
                          ),
                        ),
                        status: MissionConsoleStatus.failed,
                        expectedOutput: "10",
                        receivedOutput: "8",
                        errorReason: "AssertionError: Expected 10, got 8",
                        onRunTests: _dummyCallback,
                        onHintRequested: _dummyCallback,
                      ),
                    ),

                    const _WhitespaceSpacer(),

                    // 4. Thinking Screen
                    const _SectionHeader("4. Thinking Screen"),
                    const _PreviewContainer(
                      child: ThinkingScreen(
                        checkItems: [
                          ThinkingCheckItem(label: "Code Quality", status: ThinkingCheckItemStatus.completed),
                          ThinkingCheckItem(label: "Reasoning Pattern", status: ThinkingCheckItemStatus.analyzing),
                          ThinkingCheckItem(label: "Runtime Result", status: ThinkingCheckItemStatus.pending),
                          ThinkingCheckItem(label: "Evidence Generated", status: ThinkingCheckItemStatus.pending),
                        ],
                        statusMessage: "Updating competency...",
                      ),
                    ),
                    
                    const _WhitespaceSpacer(),

                    // 5. Competency Bar
                    const _SectionHeader("5. Competency Bar"),
                    const _PreviewContainer(
                      child: Column(
                        children: [
                          CompetencyBar(
                            title: "Small Delta",
                            oldPercentage: 0.65,
                            newPercentage: 0.66,
                          ),
                          SizedBox(height: PradigiSpacing.s32),
                          CompetencyBar(
                            title: "Medium Delta",
                            oldPercentage: 0.25,
                            newPercentage: 0.40,
                          ),
                          SizedBox(height: PradigiSpacing.s32),
                          CompetencyBar(
                            title: "Large Delta",
                            oldPercentage: 0.45,
                            newPercentage: 0.70,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _dummyCallback() {}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PradigiSpacing.s24),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: PradigiColors.textPrimary),
      ),
    );
  }
}

class _PreviewContainer extends StatelessWidget {
  final Widget child;
  const _PreviewContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PradigiSpacing.s32),
      decoration: BoxDecoration(
        color: PradigiColors.surface,
        borderRadius: BorderRadius.circular(PradigiRadius.r16),
        border: Border.all(color: PradigiColors.border),
      ),
      child: child,
    );
  }
}

class _WhitespaceSpacer extends StatelessWidget {
  const _WhitespaceSpacer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 80);
  }
}
