import 'package:flutter/material.dart';

class EvidenceExplorerPage extends StatelessWidget {
  final String conceptId;

  const EvidenceExplorerPage({super.key, required this.conceptId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidence Explorer: \$conceptId'),
      ),
      body: const Center(
        child: Text('Detailed trace of Missions, Reflections, and Execution Logs'),
      ),
    );
  }
}
