import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/arena/logic/arena_controller.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_gameplay_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ArenaLobbyPage extends StatelessWidget {
  const ArenaLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ArenaController>();
    final room = controller.currentRoom;

    if (room == null) {
      return const Scaffold(body: Center(child: Text('Room not found')));
    }

    // Auto navigate to gameplay if started
    if (room.status == 'playing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: controller,
              child: const ArenaGameplayPage(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ARENA: ${room.code}', style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: room.maxTeams,
        itemBuilder: (context, index) {
          final slot = index + 1;
          final team = room.teams.where((t) => t.slot == slot).firstOrNull;

          if (team == null) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Slot $slot: Kosong', style: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(
                    width: 120,
                    child: DuoButton(
                      text: 'BUAT TIM',
                      onPressed: () {
                        controller.createTeam('Tim Slot $slot');
                      },
                      variant: DuoButtonVariant.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1CB0F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1CB0F6), width: 2),
            ),
            child: ExpansionTile(
              title: Text('Slot $slot: ${team.name} (${team.players.length}/${room.playersPerTeam})', style: GoogleFonts.nunito(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold, fontSize: 16)),
              iconColor: const Color(0xFF1CB0F6),
              collapsedIconColor: const Color(0xFF1CB0F6),
              children: [
                ...team.players.map((p) => ListTile(
                  leading: Icon(Icons.person, color: p.isCaptain ? const Color(0xFFFF9600) : Colors.grey.shade400),
                  title: Text(p.fullName, style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.bold)),
                )),
                if (team.players.length < room.playersPerTeam)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DuoButton(
                      text: 'GABUNG TIM INI',
                      onPressed: () {
                        controller.joinTeamSlot(slot);
                      },
                      variant: DuoButtonVariant.blue,
                    ),
                  )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DuoButton(
            text: 'MULAI KOMPETISI',
            onPressed: () {
              controller.startRoom();
            },
            variant: DuoButtonVariant.green,
          ),
        ),
      ),
    );
  }
}
