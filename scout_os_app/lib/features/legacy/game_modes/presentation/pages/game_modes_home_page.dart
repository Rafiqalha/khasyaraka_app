import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/duo_theme.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../logic/game_modes_controller.dart';
import '../widgets/mode_card.dart';
import 'game_modes_lobby_page.dart';
import 'game_modes_gameplay_page.dart';

class GameModesHomePage extends StatelessWidget {
  const GameModesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameModesController>();
    final modes = ctrl.modes;

    return Scaffold(
      backgroundColor: DuoTheme.duoSnow,
      appBar: AppBar(
        backgroundColor: DuoTheme.duoWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'PRADIGI GAME',
          style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700, color: DuoTheme.duoBlack),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (ctrl.errorMsg != null) _buildError(ctrl.errorMsg!),
              if (ctrl.isLoading && modes.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else ...[
                if (ctrl.lobbyCode.isNotEmpty && ctrl.room?.status == 'lobby')
                  _buildJoinCodeBanner(ctrl.lobbyCode),
                const SizedBox(height: 8),
                Text('PILIH MODE', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: DuoTheme.duoGreyDark, letterSpacing: 2)),
                const SizedBox(height: 12),
                ...modes.map((mode) {
                  final isSelected = ctrl.selectedMode == mode.mode;
                  final playerCount = ctrl.room?.playerCount ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ModeCardWidget(
                      mode: mode,
                      isSelected: isSelected,
                      playerCount: playerCount,
                      onSelect: () => _onModeSelect(context, ctrl, mode.mode),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _buildLobbyButtons(context, ctrl),
              ],
            ],
          ),
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
            'Pilih mode permainan dan bertarung melawan pemain lain atau AI',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: DuoTheme.duoBlackLight, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DuoTheme.duoRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DuoTheme.radiusSmall),
          border: Border.all(color: DuoTheme.duoRed.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: DuoTheme.duoRed, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: DuoTheme.duoRed))),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinCodeBanner(String code) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DuoTheme.duoGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DuoTheme.radiusSmall),
          border: Border.all(color: DuoTheme.duoGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.group, color: DuoTheme.duoGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Room: ${code.toUpperCase()}',
                style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w700, color: DuoTheme.duoGreen, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onModeSelect(BuildContext context, GameModesController ctrl, String mode) async {
    if (ctrl.room == null) {
      await ctrl.createLobby();
    }
    await ctrl.selectMode(mode);
  }

  Widget _buildLobbyButtons(BuildContext context, GameModesController ctrl) {
    final inLobby = ctrl.room != null && ctrl.room!.status == 'lobby';
    final hasMode = ctrl.selectedMode.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inLobby)
          DuoButton(
            text: 'LIHAT LOBBY',
            variant: DuoButtonVariant.blue,
            isFullWidth: true,
            height: 48,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: ctrl,
                    child: GameModesLobbyPage(controller: ctrl),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 8),
        if (inLobby && hasMode)
          DuoButton(
            text: 'MULAI GAME',
            variant: DuoButtonVariant.green,
            isFullWidth: true,
            height: 56,
            onPressed: () async {
              final room = await ctrl.startGame();
              if (room != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: ctrl,
                      child: GameModesGameplayPage(controller: ctrl),
                    ),
                  ),
                );
              }
            },
          ),
        if (!inLobby)
          DuoButton(
            text: 'BUAT LOBBY',
            variant: DuoButtonVariant.green,
            isFullWidth: true,
            height: 56,
            onPressed: () => ctrl.createLobby(),
          ),
      ],
    );
  }
}
