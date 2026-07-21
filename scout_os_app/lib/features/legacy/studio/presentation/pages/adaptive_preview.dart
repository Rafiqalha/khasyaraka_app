import 'package:flutter/material.dart';

class AdaptivePreviewPage extends StatelessWidget {
  const AdaptivePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Simulator (Studio)'),
        actions: [
          DropdownButton<String>(
            value: 'beginner',
            items: const [
              DropdownMenuItem(value: 'beginner', child: Text('Beginner Persona')),
              DropdownMenuItem(value: 'expert', child: Text('Expert Persona')),
            ],
            onChanged: (val) {},
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(
        child: Text('Simulated Experience Manifest renders here...'),
      ),
    );
  }
}
