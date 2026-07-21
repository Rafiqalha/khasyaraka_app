import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/duo_theme.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../logic/game_modes_controller.dart';

class GameModesResultsPage extends StatefulWidget {
  final GameModesController controller;

  const GameModesResultsPage({super.key, required this.controller});

  @override
  State<GameModesResultsPage> createState() => _GameModesResultsPageState();
}

class _GameModesResultsPageState extends State<GameModesResultsPage> with SingleTickerProviderStateMixin {
  late GameModesController _ctrl;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller;
    _animCtrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _ctrl.gameState;
    final myScore = state?.myScore ?? 0;
    final teamAScore = state?.teamAScore ?? 0;
    final teamBScore = state?.teamBScore ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: DuoTheme.duoYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: DuoTheme.duoYellow, width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 48, color: DuoTheme.duoYellow),
                ),
                const SizedBox(height: 24),
                Text(
                  'BATTLE SELESAI!',
                  style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w800, color: DuoTheme.duoWhite),
                ),
                const SizedBox(height: 12),
                Text(
                  'Room: ${_ctrl.lobbyCode.toUpperCase()}',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: DuoTheme.duoGreyDark, letterSpacing: 2),
                ),
                const SizedBox(height: 32),
                _buildScoreboard(teamAScore, teamBScore),
                const SizedBox(height: 24),
                _buildScoreCard(myScore),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: DuoButton(
                        text: 'REMATCH',
                        variant: DuoButtonVariant.green,
                        height: 52,
                        onPressed: () {
                          _ctrl.leaveRoom();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DuoButton(
                        text: 'BERANDA',
                        variant: DuoButtonVariant.white,
                        height: 52,
                        onPressed: () {
                          _ctrl.leaveRoom();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard(int teamA, int teamB) {
    final aWins = teamA > teamB;
    final bWins = teamB > teamA;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C34),
        borderRadius: BorderRadius.circular(DuoTheme.radiusLarge),
        border: Border.all(color: const Color(0xFF2A3C44)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: aWins ? DuoTheme.duoOrange.withValues(alpha: 0.15) : DuoTheme.duoOrange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
                    border: Border.all(color: DuoTheme.duoOrange.withValues(alpha: aWins ? 0.5 : 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.flash_on, color: DuoTheme.duoOrange, size: 24),
                      const SizedBox(height: 4),
                      Text('TEAM A', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: DuoTheme.duoWhite.withValues(alpha: 0.6))),
                      const SizedBox(height: 4),
                      Text('$teamA', style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w800, color: DuoTheme.duoOrange)),
                      if (aWins) ...[
                        const SizedBox(height: 4),
                        Text('MENANG', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: DuoTheme.duoOrange)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('VS', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF4A5A64))),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bWins ? DuoTheme.duoBlue.withValues(alpha: 0.15) : DuoTheme.duoBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
                    border: Border.all(color: DuoTheme.duoBlue.withValues(alpha: bWins ? 0.5 : 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.shield, color: DuoTheme.duoBlue, size: 24),
                      const SizedBox(height: 4),
                      Text('TEAM B', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: DuoTheme.duoWhite.withValues(alpha: 0.6))),
                      const SizedBox(height: 4),
                      Text('$teamB', style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w800, color: DuoTheme.duoBlue)),
                      if (bWins) ...[
                        const SizedBox(height: 4),
                        Text('MENANG', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: DuoTheme.duoBlue)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int myScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuoTheme.duoGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DuoTheme.radiusMedium),
        border: Border.all(color: DuoTheme.duoGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, color: DuoTheme.duoYellow, size: 24),
          const SizedBox(width: 10),
          Text(
            'SKOR KAMU: $myScore',
            style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w800, color: DuoTheme.duoWhite),
          ),
        ],
      ),
    );
  }
}
