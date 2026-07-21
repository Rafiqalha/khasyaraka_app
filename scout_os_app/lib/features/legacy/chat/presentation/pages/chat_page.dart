import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/chat/logic/chat_controller.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_home_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatController()..startPolling(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    final text = _msgController.text;
    if (text.isNotEmpty) {
      context.read<ChatController>().sendMessage(text);
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Global'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show latest messages at the bottom
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                
                if (msg.msgType == 'room_invite') {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.indigo.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.campaign, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Text(msg.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(msg.message, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              // In a real app, this would route to ArenaLobby with the code
                              // For MVP, we instruct user to copy code or auto-navigate
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Buka tab Arena dan masukkan kode: ${msg.roomCode}')),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                            child: const Text('GABUNG ARENA SEKARANG'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(msg.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.teal)),
                  ),
                  title: Text(msg.fullName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(msg.message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
