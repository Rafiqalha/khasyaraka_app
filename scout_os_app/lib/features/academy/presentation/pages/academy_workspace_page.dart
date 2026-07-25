import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/academy_workspace_controller.dart';
import '../widgets/workspace_renderer.dart';
import '../../../workbench/presentation/layout/workbench_layout.dart';
// Note: We would create specific widgets for Notebook, Practice, Reflection, Evidence.
// For this vertical slice, we'll use placeholder text or basic containers for those.

class AcademyWorkspacePage extends StatelessWidget {
  final String academyId;
  final String curriculumId;

  const AcademyWorkspacePage({
    super.key,
    required this.academyId,
    required this.curriculumId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademyWorkspaceController(
      academyId: academyId,
      curriculumId: curriculumId,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              // LEFT SIDEBAR: Curriculum Tree
              Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(right: BorderSide(color: Colors.grey[800]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black45,
                      child: Text(
                        controller.curriculumTitle.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    
                    // Tree
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.units.length,
                        itemBuilder: (context, index) {
                          final unit = controller.units[index];
                          return _buildUnitSection(controller, unit);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // RIGHT PANEL: Node Renderer
              Expanded(
                child: _buildNodeRenderer(controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUnitSection(AcademyWorkspaceController controller, dynamic unit) {
    final lessons = unit['lessons'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            unit['title'].toString().toUpperCase(),
            style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        ...lessons.map((lesson) => _buildLessonSection(controller, lesson)).toList(),
      ],
    );
  }

  Widget _buildLessonSection(AcademyWorkspaceController controller, dynamic lesson) {
    final nodes = lesson['nodes'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 16, 4),
          child: Text(
            lesson['title'].toString(),
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        ...nodes.map((node) => _buildNodeItem(controller, node)).toList(),
      ],
    );
  }

  Widget _buildNodeItem(AcademyWorkspaceController controller, dynamic node) {
    final isSelected = controller.activeNodeId.value == node['id'];
    // In reality, read from controller.journeyNodes[node['id']]['status']
    final nodeState = controller.journeyNodes[node['id']] ?? {'status': 'LOCKED'};
    final status = nodeState['status'];
    
    IconData icon;
    Color iconColor;
    
    switch (status) {
      case 'COMPLETED':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'UNLOCKED':
      case 'STARTED':
        icon = Icons.circle_outlined;
        iconColor = Colors.blueAccent;
        break;
      default:
        icon = Icons.lock_outline;
        iconColor = Colors.grey[700]!;
    }

    return InkWell(
      onTap: status != 'LOCKED' ? () => controller.selectNode(node['id'], type: node['type']) : null,
      child: Container(
        color: isSelected ? Colors.blueAccent.withValues(alpha: 0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node['title'].toString(),
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : (status == 'LOCKED' ? Colors.grey[700] : Colors.white),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeRenderer(AcademyWorkspaceController controller) {
    if (controller.isDocumentLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final blocks = controller.activeDocumentBlocks;
    if (blocks.isEmpty) {
      return const Center(child: Text('No content available.', style: TextStyle(color: Colors.grey)));
    }

    return WorkspaceRenderer(blocks: blocks);
  }
}
