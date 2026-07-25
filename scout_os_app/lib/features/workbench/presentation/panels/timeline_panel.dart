import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/workbench_controller.dart';

class TimelinePanel extends StatelessWidget {
  final WorkbenchController controller = Get.find();

  TimelinePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.timeline, color: Colors.orangeAccent, size: 16),
                const SizedBox(width: 8),
                Text(
                  'COGNITIVE ACTIVITY',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Timeline Events
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.timelineEvents.length,
                  itemBuilder: (context, index) {
                    final event = controller.timelineEvents[index];
                    final timeStr = DateFormat('HH:mm:ss').format(event.timestamp);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(color: Colors.grey[600], fontSize: 11, fontFamily: 'monospace'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.summary,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
