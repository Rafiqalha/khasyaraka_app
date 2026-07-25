import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workbench_controller.dart';

class MissionPanel extends StatelessWidget {
  final WorkbenchController controller = Get.find();

  MissionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                'MISSION BRIEFING',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.missionTitle.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 12),
          Obx(() => Text(
                controller.missionNarrative.value,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  height: 1.5,
                ),
              )),
          const Spacer(),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Budget',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Obx(() => Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < controller.aiBudget.value
                            ? Icons.lightbulb
                            : Icons.lightbulb_outline,
                        color: index < controller.aiBudget.value
                            ? Colors.amber
                            : Colors.grey[700],
                        size: 16,
                      ),
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
