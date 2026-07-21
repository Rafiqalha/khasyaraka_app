import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/group_chat/logic/group_chat_controller.dart';
import 'package:scout_os_app/features/group_chat/data/group_chat_models.dart';
import 'package:scout_os_app/features/group_chat/presentation/pages/group_chat_room_page.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';

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
    return Consumer<GroupChatController>(
      builder: (context, controller, child) {
        if (controller.isLoadingRooms && controller.rooms.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final tabs = controller.availableTabs;
        if (tabs.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text('Grup Chat', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            ),
            body: Center(
              child: Text('Belum ada grup chat', style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          );
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
              title: Text('Grup Chat', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    automaticallyImplyLeading: false,
                  ),
                  TabBar(
                    isScrollable: true,
                    labelColor: const Color(0xFF1CB0F6),
                    unselectedLabelColor: Colors.grey.shade500,
                    indicatorColor: const Color(0xFF1CB0F6),
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                    tabs: tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: tabs.map((tab) {
                final rooms = controller.roomsByLevel[tab] ?? [];
                return _buildRoomList(rooms);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomList(List<GroupChatRoom> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Text(
          'Belum ada grup chat',
          style: GoogleFonts.plusJakartaSans(
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
            color: AppColors.charcoalSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (room.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      room.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white54,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
