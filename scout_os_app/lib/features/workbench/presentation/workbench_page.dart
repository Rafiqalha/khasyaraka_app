import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/workbench_controller.dart';
import 'layout/workbench_layout.dart';

class WorkbenchPage extends StatelessWidget {
  final String workspaceId;
  final String missionId;

  const WorkbenchPage({
    super.key,
    required this.workspaceId,
    required this.missionId,
  });

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(WorkbenchController());
    
    // Simulate loading the mission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadMission(missionId);
    });

    // Simulate WDL layout fetching
    final wdlLayout = [
      'mission',
      'editor',
      'terminal',
      'mentor',
      'timeline'
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              height: 48,
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () {
                      Get.delete<WorkbenchController>();
                      Get.back();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pradigi Workbench',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                        controller.isMissionComplete.value ? 'COMPLETED' : 'IN PROGRESS',
                        style: TextStyle(
                          color: controller.isMissionComplete.value ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ),
            
            // Layout Engine
            Expanded(
              child: WorkbenchLayout(wdlLayout: wdlLayout),
            ),
          ],
        ),
      ),
    );
  }
}
