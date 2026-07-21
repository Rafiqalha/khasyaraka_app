import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/duo_theme.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../data/models/game_modes_models.dart';
import '../../logic/game_modes_controller.dart';

class GameModesLobbyPage extends StatefulWidget {
  final GameModesController controller;

  const GameModesLobbyPage({super.key, required this.controller});

  @override
  State<GameModesLobbyPage> createState() => _GameModesLobbyPageState();
}

class _GameModesLobbyPageState extends State<GameModesLobbyPage> {
  late GameModesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoTheme.duoSnow,
      appBar: AppBar(
        backgroundColor: DuoTheme.duoWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DuoTheme.duoBlack),
          onPressed: () {
            _ctrl.leaveRoom();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'LOBBY GAME',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DuoTheme.duoBlack,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) {
          final room = _ctrl.room;
          if (room == null) return const SizedBox();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRoomCodeCard(room.code),
                  const SizedBox(height: 24),
                  _buildModeSection(),
                  const SizedBox(height: 24),
                  _buildPlayerSlots(room),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCodeCard(String code) {
    return Container(
      width: double.infinity,
      decoration: DuoTheme.bouncyDecoration(
        mainColor: DuoTheme.duoWhite,
        shadowColor: DuoTheme.duoBlue.withValues(alpha: 0.15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          Text(
            'KODE ROOM',
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: DuoTheme.duoGreyDark, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            code.toUpperCase(),
            style: GoogleFonts.fredoka(fontSize: 36, fontWeight: FontWeight.w800, color: DuoTheme.duoBlue, letterSpacing: 6),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSection() {
    final selectedMode = _ctrl.selectedMode;
    final modeLabels = {
      '2v2': '⚔️ 2 vs 2 — Attacker & Defender',
      '1v1_ai': '🤖 1 vs 1 — Latihan AI',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODE PERMAINAN',
          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: DuoTheme.duoGreyDark, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Row(
          children: modeLabels.entries.map((entry) {
            final isSelected = selectedMode == entry.key;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == modeLabels.keys.first ? 8 : 0,
                  left: entry.key == modeLabels.keys.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => _ctrl.selectMode(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: DuoTheme.bouncyDecoration(
                      mainColor: isSelected ? DuoTheme.duoBlue : DuoTheme.duoWhite,
                      shadowColor: isSelected ? DuoTheme.duoBlue : DuoTheme.duoGrey,
                    ),
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? DuoTheme.duoWhite : DuoTheme.duoBlack,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerSlots(GameRoom room) {
    final slots = [
      {'label': 'Team A — Attacker', 'id': room.teamAAttacker, 'emoji': '🗡️', 'team': 'A', 'role': 'Attacker'},
      {'label': 'Team A — Defender', 'id': room.teamADefender, 'emoji': '🛡️', 'team': 'A', 'role': 'Defender'},
      {'label': 'Team B — Attacker', 'id': room.teamBAttacker, 'emoji': '🗡️', 'team': 'B', 'role': 'Attacker'},
      {'label': 'Team B — Defender', 'id': room.teamBDefender, 'emoji': '🛡️', 'team': 'B', 'role': 'Defender'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SLOT PEMAIN (${room.playerCount}/4)',
          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: DuoTheme.duoGreyDark, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        ...slots.map((slot) {
          final filled = slot['id'] != null;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: filled ? DuoTheme.duoGreen.withValues(alpha: 0.06) : DuoTheme.duoWhite,
              borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
              border: Border.all(
                color: filled ? DuoTheme.duoGreen.withValues(alpha: 0.3) : DuoTheme.duoGrey.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(slot['emoji'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot['label'] as String,
                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: DuoTheme.duoBlack),
                      ),
                    ],
                  ),
                ),
                if (filled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DuoTheme.duoGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 14, color: DuoTheme.duoWhite),
                        const SizedBox(width: 4),
                        Text(
                          'SIAP',
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: DuoTheme.duoWhite, letterSpacing: 1),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DuoTheme.duoGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MENUNGGU',
                      style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: DuoTheme.duoWhite, letterSpacing: 1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStartButton() {
    final selected = _ctrl.selectedMode.isNotEmpty;
    return DuoButton(
      text: selected ? 'MULAI GAME' : 'PILIH MODE DULU',
      variant: selected ? DuoButtonVariant.green : DuoButtonVariant.white,
      isFullWidth: true,
      height: 56,
      onPressed: selected
          ? () async {
              final room = await _ctrl.startGame();
              if (room != null && mounted) {
                Navigator.pushReplacementNamed(context, '/game-modes-gameplay', arguments: _ctrl);
              }
            }
          : null,
    );
  }
}
