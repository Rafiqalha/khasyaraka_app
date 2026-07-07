import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/arena/logic/arena_controller.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_lobby_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:scout_os_app/core/config/feature_flags.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_matchmaking_page.dart';

class ArenaHomePage extends StatelessWidget {
  const ArenaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArenaController(),
      child: const _ArenaHomeView(),
    );
  }
}

class _ArenaHomeView extends StatefulWidget {
  const _ArenaHomeView();

  @override
  State<_ArenaHomeView> createState() => _ArenaHomeViewState();
}

class _ArenaHomeViewState extends State<_ArenaHomeView> {
  final TextEditingController _codeController = TextEditingController();

  void _createRoom() async {
    final controller = context.read<ArenaController>();
    await controller.createRoom();
    if (controller.currentRoom != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: controller,
            child: const ArenaLobbyPage(),
          ),
        ),
      );
    } else if (controller.errorMsg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMsg!)),
      );
    }
  }

  void _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final controller = context.read<ArenaController>();
    await controller.joinRoom(code);
    if (controller.currentRoom != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: controller,
            child: const ArenaLobbyPage(),
          ),
        ),
      );
    } else if (controller.errorMsg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMsg!)),
      );
    }
  }

  void _start1v1Matchmaking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArenaMatchmakingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ArenaController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(FeatureFlags.enableTeamMode ? 'CYBER-SCOUT ARENA 5v5' : 'ARENA DUEL 1v1', style: GoogleFonts.fredoka(color: const Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.stadium, size: 100, color: Color(0xFF1CB0F6)),
            const SizedBox(height: 32),
            if (controller.isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF1CB0F6)))
            else if (!FeatureFlags.enableTeamMode) ...[
              DuoButton(
                text: 'CARI LAWAN (1v1)',
                icon: Icons.search,
                onPressed: _start1v1Matchmaking,
                variant: DuoButtonVariant.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'Sistem akan mencarikan lawan sepadan untuk berduel secara real-time!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              DuoButton(
                text: 'BUAT ARENA BARU',
                icon: Icons.add,
                onPressed: _createRoom,
                variant: DuoButtonVariant.blue,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE5E5E5), thickness: 2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ATAU', style: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE5E5E5), thickness: 2)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Kode Arena (Misal: PRDA7X)',
                  labelStyle: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1CB0F6), width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF1CB0F6)),
                    onPressed: _joinRoom,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _joinRoom(),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
