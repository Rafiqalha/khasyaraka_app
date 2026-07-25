import 'package:flutter/material.dart';
import '../panels/editor_panel.dart';
import '../panels/mission_panel.dart';
import '../panels/terminal_panel.dart';
import '../panels/mentor_panel.dart';
import '../panels/timeline_panel.dart';

// ===========================
// Workbench Layout Engine
// Renders panels dynamically based on WDL manifest.
// ===========================

class WorkbenchLayout extends StatelessWidget {
  final List<String> wdlLayout;

  const WorkbenchLayout({
    super.key,
    required this.wdlLayout,
  });

  Widget _buildPanel(String name) {
    switch (name) {
      case 'mission':
        return MissionPanel();
      case 'editor':
        return const EditorPanel();
      case 'terminal':
        return TerminalPanel();
      case 'mentor':
        return MentorPanel();
      case 'timeline':
        return TimelinePanel();
      default:
        return Center(child: Text('Unknown Panel: \$name'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // For Phase A, we hardcode a split view based on the mock WDL.
    // Left: Mission
    // Middle: Editor (top) + Terminal (bottom)
    // Right: Mentor (top) + Timeline (bottom)
    
    // In a real implementation, we'd use a flexible docking package like 'split_view' or 'multi_split_view'.
    
    return Row(
      children: [
        // LEFT COLUMN (Mission)
        if (wdlLayout.contains('mission'))
          Expanded(
            flex: 2,
            child: _buildPanel('mission'),
          ),
        
        // MIDDLE COLUMN (Editor + Terminal)
        Expanded(
          flex: 5,
          child: Column(
            children: [
              if (wdlLayout.contains('editor'))
                Expanded(
                  flex: 3,
                  child: _buildPanel('editor'),
                ),
              if (wdlLayout.contains('editor') && wdlLayout.contains('terminal'))
                Container(height: 1, color: Colors.grey[800]), // Divider
              if (wdlLayout.contains('terminal'))
                Expanded(
                  flex: 1,
                  child: _buildPanel('terminal'),
                ),
            ],
          ),
        ),
        
        // RIGHT COLUMN (Mentor + Timeline)
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Column(
              children: [
                if (wdlLayout.contains('mentor'))
                  Expanded(
                    flex: 2,
                    child: _buildPanel('mentor'),
                  ),
                if (wdlLayout.contains('mentor') && wdlLayout.contains('timeline'))
                  Container(height: 1, color: Colors.grey[800]), // Divider
                if (wdlLayout.contains('timeline'))
                  Expanded(
                    flex: 1,
                    child: _buildPanel('timeline'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
