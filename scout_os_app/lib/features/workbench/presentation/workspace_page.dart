import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'workbench_page.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Academies & Workspaces'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAcademyCard(
            context,
            title: 'Python Academy',
            icon: Icons.code,
            color: Colors.blueAccent,
            workspaces: [
              _WorkspaceItem(
                id: 'python_debugging_ws',
                title: 'Debugging Workspace',
                description: 'Master fixing logical and syntax errors in Python.',
                missionId: 'bug_001',
              ),
              _WorkspaceItem(
                id: 'python_algo_ws',
                title: 'Algorithm Workspace',
                description: 'Solve complex algorithmic challenges.',
                missionId: 'algo_001',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAcademyCard(
            context,
            title: 'Cyber Academy',
            icon: Icons.security,
            color: Colors.redAccent,
            workspaces: [
              _WorkspaceItem(
                id: 'cyber_soc_ws',
                title: 'SOC Analyst Workspace',
                description: 'Investigate logs and respond to incidents.',
                missionId: 'soc_001',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademyCard(BuildContext context, {required String title, required IconData icon, required Color color, required List<_WorkspaceItem> workspaces}) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...workspaces.map((ws) => _buildWorkspaceTile(context, ws)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceTile(BuildContext context, _WorkspaceItem ws) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(ws.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(ws.description, style: TextStyle(color: Colors.grey[400])),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        onPressed: () {
          Get.to(() => WorkbenchPage(
            workspaceId: ws.id,
            missionId: ws.missionId,
          ));
        },
        child: const Text('Enter Workspace'),
      ),
    );
  }
}

class _WorkspaceItem {
  final String id;
  final String title;
  final String description;
  final String missionId;

  _WorkspaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.missionId,
  });
}
