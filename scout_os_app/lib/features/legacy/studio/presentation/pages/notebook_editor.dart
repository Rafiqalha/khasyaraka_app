import 'package:flutter/material.dart';

class NotebookEditorPage extends StatelessWidget {
  const NotebookEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notebook Block Editor (Studio)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () {},
            tooltip: 'Add Block',
          )
        ],
      ),
      body: const Center(
        child: Text('Block Editor UI goes here (Markdown, Sandbox, Mission)'),
      ),
    );
  }
}
