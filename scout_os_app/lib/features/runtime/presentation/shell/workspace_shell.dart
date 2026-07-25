import 'package:flutter/material.dart';
import 'package:scout_os_app/design_system/tokens/colors.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../panels/editor_panel.dart';
import '../panels/console_panel.dart';
import '../panels/analysis_panel.dart';
import '../providers/runtime_provider.dart';
import '../../../os/data/models/home_data_model.dart';

class WorkspaceShell extends ConsumerWidget {
  const WorkspaceShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentSessionProvider);

    return sessionAsync.when(
      data: (data) {
        final node = data.node;
        final session = data.session;
        if (node == null || session == null) {
          return const Scaffold(body: Center(child: Text('No active activity found.')));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Today's Objective", 
                    style: PradigiTypography.caption.copyWith(fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.title, 
                    style: PradigiTypography.caption.copyWith(color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  flex: 2,
                  child: Text(
                    "Why now? Because every production application communicates through HTTP before touching an LLM.", 
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;
              final children = [
                // Left/Top Panel: Editor
                Expanded(
                  flex: 5,
                  child: WorkspaceEditorPanel(
                    initialCode: node.initialCode,
                    language: node.language,
                    sessionId: session.id,
                    nodeId: node.id,
                  ),
                ),
                
                // Divider
                Container(
                  width: isDesktop ? 1 : double.infinity,
                  height: isDesktop ? double.infinity : 1,
                  color: Colors.grey.shade200,
                ),
                
                // Right/Bottom Panel: Console
                const Expanded(
                  flex: 5,
                  child: WorkspaceConsolePanel(),
                ),
              ];

              if (isDesktop) {
                return Row(children: children);
              } else {
                return Column(children: children);
              }
            },
          ),
          );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black))),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
