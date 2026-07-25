import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/design_system/tokens/typography.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/workspace_controller.dart';

class WorkspaceConsolePanel extends ConsumerWidget {
  const WorkspaceConsolePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceData = ref.watch(workspaceProvider);
    final logs = workspaceData.consoleLogs;

    if (workspaceData.state == WorkspaceState.idle) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Text(
              'Terminal',
              style: PradigiTypography.caption.copyWith(color: const Color(0xFF8B949E)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: logs.map((log) {
                    Color color = const Color(0xFFC9D1D9);
                    
                    if (log.contains('scout@sandbox:~')) {
                      color = const Color(0xFF3FB950);
                    } else if (log.contains('failed') || log.contains('non-zero exit code') || log.contains('DIAGNOSIS:') || log.contains('SUGGESTION:')) {
                      color = const Color(0xFFF85149);
                    } else if (log.contains('All tests passed')) {
                      color = const Color(0xFF3FB950);
                    } else if (log.contains('[sandbox]')) {
                      color = const Color(0xFF8B949E);
                    } else if (log.contains('[pradigi-os]')) {
                      color = const Color(0xFF58A6FF);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        log,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
