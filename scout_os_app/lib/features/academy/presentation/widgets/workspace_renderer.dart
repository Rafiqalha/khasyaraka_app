import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../workbench/presentation/controllers/workbench_controller.dart';
// Note: In production we'd import 'flutter_markdown' and 'highlight'.

class WorkspaceRenderer extends StatelessWidget {
  final List<dynamic> blocks;

  const WorkspaceRenderer({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return _buildBlock(context, block);
      },
    );
  }

  Widget _buildBlock(BuildContext context, dynamic block) {
    final type = block['type'] ?? 'unknown';

    switch (type) {
      case 'markdown':
        return _MarkdownBlock(content: block['content']);
      case 'adaptive':
        return _AdaptiveBlock(id: block['id'], data: block['data']);
      case 'code':
        return _CodeBlock(
          language: block['language'],
          content: block['content'],
          fixture: block['fixture'],
        );
      case 'mission':
        return _MissionBlock(data: block['data']);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _MarkdownBlock extends StatelessWidget {
  final String content;
  const _MarkdownBlock({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        content,
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
      ),
    );
  }
}

class _AdaptiveBlock extends StatelessWidget {
  final String id;
  final Map<String, dynamic>? data;

  const _AdaptiveBlock({required this.id, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!['resolved_text'] == null) {
      // Planner decided this user doesn't need this adaptive block.
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        border: Border(left: BorderSide(color: Colors.blueAccent, width: 4)),
      ),
      child: Text(
        data!['resolved_text'],
        style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontStyle: FontStyle.italic),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String language;
  final String content;
  final String? fixture;

  const _CodeBlock({required this.language, required this.content, this.fixture});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Inline execution logic would go here
                      },
                      icon: const Icon(Icons.play_arrow, size: 14),
                      label: const Text('Run'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Open full workbench
                        if (fixture != null) {
                          Get.find<WorkbenchController>().loadMission(fixture!);
                        }
                      },
                      child: const Text('Open in Workbench', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                    )
                  ],
                ),
              ],
            ),
          ),
          
          // Code Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionBlock extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _MissionBlock({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch, color: Colors.purple, size: 32),
          const SizedBox(height: 16),
          const Text('Ready for the Mission?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Difficulty: ${data?['difficulty'] ?? 'Standard'} | Constraint: ${data?['constraint'] ?? 'None'}", 
            style: const TextStyle(color: Colors.purpleAccent)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Launch Workbench'),
          )
        ],
      ),
    );
  }
}
