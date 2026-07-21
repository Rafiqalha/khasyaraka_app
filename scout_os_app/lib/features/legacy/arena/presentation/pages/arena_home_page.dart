import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/arena/logic/arena_controller.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_lobby_page.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_matchmaking_page.dart';
import 'package:scout_os_app/core/config/duo_theme.dart';
import 'package:scout_os_app/features/game_modes/logic/game_modes_controller.dart';
import 'package:scout_os_app/features/game_modes/presentation/pages/game_modes_lobby_page.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

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
  final GameModesController _gameCtrl = GameModesController();

  @override
  void initState() {
    super.initState();
    _initGameCtrl();
  }

  Future<void> _initGameCtrl() async {
    final token = await ApiDioProvider.getToken();
    int userId = 0;
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          String payload = parts[1];
          while (payload.length % 4 != 0) payload += '=';
          final json = jsonDecode(utf8.decode(base64Url.decode(payload)));
          userId = json['sub'] ?? 0;
          userId = int.tryParse(userId.toString()) ?? 0;
        }
      } catch (_) {}
    }
    _gameCtrl.init(userId);
  }

  Future<void> _create2v2Lobby() async {
    await _gameCtrl.createLobby();
    if (_gameCtrl.lobbyCode.isNotEmpty && mounted) {
      await _gameCtrl.selectMode('2v2');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: _gameCtrl,
            child: GameModesLobbyPage(controller: _gameCtrl),
          ),
        ),
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
      backgroundColor: DuoTheme.duoSnow,
      appBar: AppBar(
        title: Text('PRADIGI GAME', style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700, color: DuoTheme.duoBlack)),
        backgroundColor: DuoTheme.duoWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildHeader(),
              const SizedBox(height: 24),
              _buildModeCard2v2(context),
              const SizedBox(height: 12),
              _buildModeCard1v1(context),
              const SizedBox(height: 24),
              _buildJoinSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DuoTheme.duoWhite,
        borderRadius: BorderRadius.circular(DuoTheme.radiusLarge),
        border: Border.all(color: DuoTheme.duoGrey),
        boxShadow: [BoxShadow(color: DuoTheme.duoGreyDark.withValues(alpha: 0.12), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DuoTheme.duoOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DuoTheme.radiusLarge),
            ),
            child: const Icon(Icons.shield_moon_rounded, size: 36, color: DuoTheme.duoOrange),
          ),
          const SizedBox(height: 16),
          Text(
            'Simulasi Keamanan Siber',
            style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700, color: DuoTheme.duoBlack),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih mode permainan dan bertarung',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: DuoTheme.duoBlackLight),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard2v2(BuildContext context) {
    return GestureDetector(
      onTap: _create2v2Lobby,
      child: Container(
        width: double.infinity,
        decoration: DuoTheme.bouncyDecoration(
          mainColor: DuoTheme.duoWhite,
          shadowColor: DuoTheme.duoOrange.withValues(alpha: 0.2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: DuoTheme.duoOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
                  ),
                  child: const Icon(Icons.groups_rounded, size: 28, color: DuoTheme.duoOrange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2 vs 2 — Attacker & Defender', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: DuoTheme.duoBlack)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: DuoTheme.duoGreyDark),
                          const SizedBox(width: 4),
                          Text('4 pemain', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: DuoTheme.duoGreyDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: DuoTheme.duoOrange, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1 tim = 1 Attacker + 1 Defender. Bertanding dalam simulasi keamanan siber melawan tim lain.',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: DuoTheme.duoBlackLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard1v1(BuildContext context) {
    return GestureDetector(
      onTap: _start1v1Matchmaking,
      child: Container(
        width: double.infinity,
        decoration: DuoTheme.bouncyDecoration(
          mainColor: DuoTheme.duoWhite,
          shadowColor: DuoTheme.duoBlue.withValues(alpha: 0.2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: DuoTheme.duoBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, size: 28, color: DuoTheme.duoBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1 vs 1 — Duel with AI', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: DuoTheme.duoBlack)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: DuoTheme.duoGreyDark),
                          const SizedBox(width: 4),
                          Text('1 pemain', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: DuoTheme.duoGreyDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: DuoTheme.duoBlue, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Hadapi AI dengan soal yang menyesuaikan level berdasarkan XP akumulasi pemain.',
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: DuoTheme.duoBlackLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: DuoTheme.duoGrey, thickness: 2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ATAU GABUNG ROOM', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: DuoTheme.duoGreyDark, letterSpacing: 1)),
            ),
            const Expanded(child: Divider(color: DuoTheme.duoGrey, thickness: 2)),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeController,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 18, color: DuoTheme.duoBlack),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Masukkan kode room',
            hintStyle: GoogleFonts.nunito(color: DuoTheme.duoGreyDark, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: DuoTheme.duoWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
              borderSide: const BorderSide(color: DuoTheme.duoGrey, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
              borderSide: const BorderSide(color: DuoTheme.duoGrey, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
              borderSide: const BorderSide(color: DuoTheme.duoOrange, width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward, color: DuoTheme.duoOrange),
              onPressed: _joinRoom,
            ),
          ),
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (_) => _joinRoom(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _gameCtrl.dispose();
    super.dispose();
  }
}
