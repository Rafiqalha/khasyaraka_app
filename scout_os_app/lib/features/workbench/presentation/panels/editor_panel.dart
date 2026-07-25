import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../controllers/workbench_controller.dart';

class EditorPanel extends StatefulWidget {
  const EditorPanel({super.key});

  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  final WorkbenchController controller = Get.find();
  late CodeController codeController;

  @override
  void initState() {
    super.initState();
    // Initialize the code controller from the global GetX controller
    // but we configure the language specific to the UI rendering here
    codeController = CodeController(
      text: controller.codeController.text,
      language: python,
    );
    
    // Sync back changes to the main controller
    codeController.addListener(() {
      controller.codeController.text = codeController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF23241F), // Monokai background
      child: Column(
        children: [
          // Editor Header Tab
          Container(
            color: Colors.black45,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.code, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 8),
                Obx(() => Text(
                      controller.currentFile.value,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )),
                const Spacer(),
                Obx(() => ElevatedButton.icon(
                      onPressed: controller.isRunning.value
                          ? null
                          : () => controller.runCode(),
                      icon: controller.isRunning.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow, size: 16),
                      label: Text(controller.isRunning.value ? 'Running...' : 'Run'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 32),
                      ),
                    )),
              ],
            ),
          ),
          
          // Actual Editor
          Expanded(
            child: SingleChildScrollView(
              child: CodeTheme(
                data: CodeThemeData(styles: monokaiSublimeTheme),
                child: CodeField(
                  controller: codeController,
                  textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  expands: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
