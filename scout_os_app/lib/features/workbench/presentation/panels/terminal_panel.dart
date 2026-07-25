import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workbench_controller.dart';

class TerminalPanel extends StatelessWidget {
  final WorkbenchController controller = Get.find();

  TerminalPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Terminal Header
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Text(
                  'TERMINAL',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Terminal Output
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Obx(() {
                if (controller.terminalOutput.isEmpty) {
                  return const Text(
                    'Workspace ready.\nWaiting for commands...',
                    style: TextStyle(color: Colors.white54, fontFamily: 'monospace'),
                  );
                }
                return ListView.builder(
                  itemCount: controller.terminalOutput.length,
                  itemBuilder: (context, index) {
                    final line = controller.terminalOutput[index];
                    Color textColor = Colors.white;
                    if (line.startsWith('Error') || line.startsWith('Exception')) {
                      textColor = Colors.redAccent;
                    } else if (line.startsWith('\$')) {
                      textColor = Colors.greenAccent;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        line,
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
