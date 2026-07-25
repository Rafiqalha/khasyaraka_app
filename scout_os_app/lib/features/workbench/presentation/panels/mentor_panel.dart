import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workbench_controller.dart';

class MentorPanel extends StatelessWidget {
  final WorkbenchController controller = Get.find();
  final TextEditingController textController = TextEditingController();

  MentorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.black45,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.purpleAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'AI MENTOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                      '${controller.aiBudget.value} left',
                      style: TextStyle(
                        color: controller.aiBudget.value > 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    )),
              ],
            ),
          ),
          
          // Chat History
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.chatHistory.length + (controller.isMentorTyping.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.chatHistory.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Mentor is thinking...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                      );
                    }
                    final msg = controller.chatHistory[index];
                    final isUser = msg.sender == 'User';
                    
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[800] : Colors.grey[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    );
                  },
                )),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black26,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask for a hint...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        controller.askMentor(val);
                        textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.blueAccent,
                      onPressed: controller.aiBudget.value <= 0 || controller.isMentorTyping.value
                          ? null
                          : () {
                              if (textController.text.trim().isNotEmpty) {
                                controller.askMentor(textController.text);
                                textController.clear();
                              }
                            },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
