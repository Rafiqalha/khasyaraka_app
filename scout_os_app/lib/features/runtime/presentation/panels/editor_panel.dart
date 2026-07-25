import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:scout_os_app/design_system/tokens/spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/workspace_controller.dart';

// GitHub Dark Monaco-like theme for highlight
const Map<String, TextStyle> monacoTheme = {
  'root': TextStyle(backgroundColor: Color(0xFF0D1117), color: Color(0xFFC9D1D9)),
  'keyword': TextStyle(color: Color(0xFFFF7B72)),
  'built_in': TextStyle(color: Color(0xFF79C0FF)),
  'type': TextStyle(color: Color(0xFF79C0FF)),
  'literal': TextStyle(color: Color(0xFF79C0FF)),
  'number': TextStyle(color: Color(0xFF79C0FF)),
  'string': TextStyle(color: Color(0xFFA5D6FF)),
  'title': TextStyle(color: Color(0xFFD2A8FF)),
  'section': TextStyle(color: Color(0xFFD2A8FF)),
  'name': TextStyle(color: Color(0xFF7EE787)),
  'comment': TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
  'meta': TextStyle(color: Color(0xFF8B949E)),
  'params': TextStyle(color: Color(0xFFC9D1D9)),
};

class WorkspaceEditorPanel extends ConsumerStatefulWidget {
  final String initialCode;
  final String language;
  final String sessionId;
  final String nodeId;

  const WorkspaceEditorPanel({
    super.key,
    required this.initialCode,
    required this.sessionId,
    required this.nodeId,
    this.language = 'python',
  });

  @override
  ConsumerState<WorkspaceEditorPanel> createState() => _WorkspaceEditorPanelState();
}

class _WorkspaceEditorPanelState extends ConsumerState<WorkspaceEditorPanel> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialCode,
      language: python,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceProvider).state;
    final isRunning = workspaceState == WorkspaceState.running;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code, color: Color(0xFF8B949E), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'main.py',
                      style: PradigiTypography.caption.copyWith(color: const Color(0xFF8B949E)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                         // Ask AI feature
                      },
                      icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B949E)),
                      label: Text("Ask AI", style: PradigiTypography.caption.copyWith(color: const Color(0xFF8B949E))),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      onPressed: isRunning
                          ? null
                          : () {
                              ref.read(workspaceProvider.notifier).runCode(
                                    code: _codeController.text,
                                    language: widget.language,
                                    sessionId: widget.sessionId,
                                    nodeId: widget.nodeId,
                                  );
                            },
                      icon: isRunning
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.play_arrow, size: 14),
                      label: Text(isRunning ? "Running" : "Run"),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Editor
          CodeTheme(
            data: CodeThemeData(styles: monacoTheme),
            child: Container(
              color: const Color(0xFF0D1117),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
                child: SingleChildScrollView(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                      ),
                    ),
                    child: CodeField(
                      controller: _codeController,
                      background: Colors.transparent,
                      textStyle: GoogleFonts.jetBrainsMono(fontSize: 14),
                      gutterStyle: GutterStyle(
                        textStyle: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF484F58),
                          fontSize: 14,
                        ),
                        showLineNumbers: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
