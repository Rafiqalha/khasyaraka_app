import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/components/thinking_screen.dart';

class ThinkingPage extends ConsumerStatefulWidget {
  const ThinkingPage({super.key});

  @override
  ConsumerState<ThinkingPage> createState() => _ThinkingPageState();
}

class _ThinkingPageState extends ConsumerState<ThinkingPage> {
  List<ThinkingCheckItem> _items = const [
    ThinkingCheckItem(label: "Runtime Result", status: ThinkingCheckItemStatus.analyzing),
    ThinkingCheckItem(label: "Evidence Generated", status: ThinkingCheckItemStatus.pending),
    ThinkingCheckItem(label: "Competency Updated", status: ThinkingCheckItemStatus.pending),
  ];
  String _statusMessage = "Analyzing runtime metrics...";

  @override
  void initState() {
    super.initState();
    _simulateBackendProcess();
  }

  void _simulateBackendProcess() async {
    // Stage 1: Runtime
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _items = [
        const ThinkingCheckItem(label: "Runtime Result", status: ThinkingCheckItemStatus.completed),
        const ThinkingCheckItem(label: "Evidence Generated", status: ThinkingCheckItemStatus.analyzing),
        const ThinkingCheckItem(label: "Competency Updated", status: ThinkingCheckItemStatus.pending),
      ];
      _statusMessage = "Generating learning evidence...";
    });

    // Stage 2: Evidence
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _items = [
        const ThinkingCheckItem(label: "Runtime Result", status: ThinkingCheckItemStatus.completed),
        const ThinkingCheckItem(label: "Evidence Generated", status: ThinkingCheckItemStatus.completed),
        const ThinkingCheckItem(label: "Competency Updated", status: ThinkingCheckItemStatus.analyzing),
      ];
      _statusMessage = "Updating competency graph...";
    });

    // Stage 3: Competency
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _items = [
        const ThinkingCheckItem(label: "Runtime Result", status: ThinkingCheckItemStatus.completed),
        const ThinkingCheckItem(label: "Evidence Generated", status: ThinkingCheckItemStatus.completed),
        const ThinkingCheckItem(label: "Competency Updated", status: ThinkingCheckItemStatus.completed),
      ];
      _statusMessage = "Analysis complete.";
    });
    
    // In reality, this would trigger the JourneyController to automatically advance to the next node (e.g., Quick Check or Passport) once the backend acknowledges completion.
  }

  @override
  Widget build(BuildContext context) {
    return ThinkingScreen(
      checkItems: _items,
      statusMessage: _statusMessage,
    );
  }
}
