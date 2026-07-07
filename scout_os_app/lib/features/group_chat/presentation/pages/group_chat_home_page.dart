import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/group_chat/logic/group_chat_controller.dart';
import 'package:scout_os_app/features/group_chat/data/group_chat_models.dart';
import 'package:scout_os_app/features/group_chat/presentation/pages/group_chat_room_page.dart';

class GroupChatHomePage extends StatefulWidget {
  const GroupChatHomePage({super.key});

  @override
  State<GroupChatHomePage> createState() => _GroupChatHomePageState();
}

class _GroupChatHomePageState extends State<GroupChatHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupChatController>().initChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: Text(
          'Grup Chat 💬',
          style: GoogleFonts.nunito(
            color: const Color(0xFF2C3E50),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Consumer<GroupChatController>(
        builder: (context, controller, child) {
          if (controller.isLoadingRooms && controller.rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildRoomList(controller.rooms);
        },
      ),
    );
  }

  Widget _buildRoomList(List<GroupChatRoom> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Text(
          'Belum ada grup chat',
          style: GoogleFonts.nunito(
            color: Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildRoomCard(GroupChatRoom room) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatRoomPage(room: room),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE5E5E5),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1CB0F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.group_rounded,
                color: Color(0xFF1CB0F6),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4B4B4B),
                    ),
                  ),
                  if (room.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      room.description!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCECECE),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
