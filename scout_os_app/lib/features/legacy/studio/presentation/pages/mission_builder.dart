import 'package:flutter/material.dart';

class MissionBuilderPage extends StatelessWidget {
  const MissionBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Builder (Studio)'),
      ),
      body: const Center(
        child: Text('Mission Configuration UI (Runtime, Evaluation, Constraints)'),
      ),
    );
  }
}
