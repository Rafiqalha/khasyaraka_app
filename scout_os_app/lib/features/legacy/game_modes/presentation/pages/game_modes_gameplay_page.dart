import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/duo_theme.dart';
import '../../data/models/game_modes_models.dart';
import '../../logic/game_modes_controller.dart';

class GameModesGameplayPage extends StatefulWidget {
  final GameModesController controller;

  const GameModesGameplayPage({super.key, required this.controller});

  @override
  State<GameModesGameplayPage> createState() => _GameModesGameplayPageState();
}

class _GameModesGameplayPageState extends State<GameModesGameplayPage> {
  late GameModesController _ctrl;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isAttacking = false;
  Timer? _roundTimer;
  int _timeLeft = 10;

  static const _terminalBg = Color(0xFF0A0A0A);
  static const _terminalGreen = Color(0xFF00FF41);
  static const _terminalCyan = Color(0xFF00F0FF);
  static const _terminalRed = Color(0xFFFF5555);
  static const _terminalYellow = Color(0xFFFFD600);

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller;
    _findMyRole();
    _startRoundTimer();
  }

  void _findMyRole() {
    final room = _ctrl.room;
    if (room != null) {
      final round = _ctrl.gameState?.round;
      if (round != null && round.attackerTeam == 1) {
        _isAttacking = room.teamAAttacker == _ctrl.lobbyCode.hashCode;
      }
    }
  }

  void _startRoundTimer() {
    _roundTimer?.cancel();
    _timeLeft = (_ctrl.room?.mode == '2v2') ? 60 : 10;
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _roundTimer?.cancel();
    super.dispose();
  }

  void _submitAction() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.submitAction(text);
    _inputCtrl.clear();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) => _buildBody(),
      ),
      bottomNavigationBar: _buildTerminalInput(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DuoTheme.duoWhite),
        onPressed: () {
          _ctrl.leaveRoom();
          Navigator.pop(context);
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.terminal, size: 18, color: _terminalGreen),
          const SizedBox(width: 8),
          Text(
            'ROUND ${_ctrl.gameState?.round?.roundNum ?? '...'}',
            style: GoogleFonts.sourceCodePro(fontSize: 15, fontWeight: FontWeight.w700, color: _terminalGreen),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildTimerBadge(),
        ),
      ],
    );
  }

  Widget _buildTimerBadge() {
    final color = _timeLeft <= 3 ? _terminalRed : _terminalYellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${_timeLeft}s',
            style: GoogleFonts.sourceCodePro(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final state = _ctrl.gameState;
    if (state == null) return const Center(child: CircularProgressIndicator(color: _terminalGreen));

    return SafeArea(
      child: Column(
        children: [
          _buildScoreBar(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: state.actions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildScenarioCard(state);
                final action = state.actions[state.actions.length - 1 - index];
                return _buildTerminalBlock(action);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar() {
    final state = _ctrl.gameState;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          _buildTeamScore('ATTACKER', state?.teamAScore ?? 0, _terminalRed),
          const SizedBox(width: 4),
          Text('VS', style: GoogleFonts.sourceCodePro(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF484F58))),
          const SizedBox(width: 4),
          _buildTeamScore('DEFENDER', state?.teamBScore ?? 0, _terminalCyan),
          const Spacer(),
          if (_isAttacking)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _terminalRed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('ATTACK', style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.w700, color: _terminalRed)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _terminalCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('DEFEND', style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.w700, color: _terminalCyan)),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String label, int score, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF8B949E))),
        const SizedBox(width: 6),
        Text('$score', style: GoogleFonts.sourceCodePro(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildScenarioCard(GameState state) {
    final round = state.round;
    final scenario = round?.scenario ?? '';
    if (scenario.isEmpty) return const SizedBox(height: 4);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _terminalCyan.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: _terminalCyan, width: 3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, size: 14, color: _terminalCyan.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text('[ SCENARIO ]', style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.w700, color: _terminalCyan.withValues(alpha: 0.6), letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scenario,
            style: GoogleFonts.sourceCodePro(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFC9D1D9), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalBlock(GameAction action) {
    final isOutput = action.output.isNotEmpty;
    final outputColor = isOutput ? _terminalGreen : _terminalCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _terminalBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
              border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
            ),
            child: Row(
              children: [
                _windowDot(_terminalRed),
                const SizedBox(width: 6),
                _windowDot(_terminalYellow),
                const SizedBox(width: 6),
                _windowDot(_terminalGreen),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'root@khasyaraka:~',
                    style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF8B949E)),
                  ),
                ),
                const Spacer(),
                Text(
                  '${action.scoreChange >= 0 ? "+" : ""}${action.scoreChange}',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: action.scoreChange >= 0 ? _terminalGreen : _terminalRed,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'root@khasyaraka:~# ',
                        style: GoogleFonts.sourceCodePro(fontSize: 12, fontWeight: FontWeight.w700, color: _terminalGreen),
                      ),
                      TextSpan(
                        text: action.input,
                        style: GoogleFonts.sourceCodePro(fontSize: 12, fontWeight: FontWeight.w600, color: DuoTheme.duoWhite),
                      ),
                    ],
                  ),
                ),
                if (action.output.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      action.output,
                      style: GoogleFonts.sourceCodePro(fontSize: 12, fontWeight: FontWeight.w500, color: outputColor, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _windowDot(Color color) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _buildTerminalInput() {
    return Container(
      padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _terminalBg,
          border: Border(top: BorderSide(color: const Color(0xFF30363D).withValues(alpha: 0.5))),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'root@khasyaraka:~# ',
                style: GoogleFonts.sourceCodePro(fontSize: 14, fontWeight: FontWeight.w700, color: _terminalGreen),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                maxLines: null,
                style: GoogleFonts.sourceCodePro(fontSize: 14, fontWeight: FontWeight.w600, color: DuoTheme.duoWhite),
                cursorColor: _terminalGreen,
                decoration: InputDecoration(
                  hintText: _isAttacking ? 'type attack command...' : 'type defense command...',
                  hintStyle: GoogleFonts.sourceCodePro(fontSize: 14, color: const Color(0xFF30363D)),
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _submitAction(),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _submitAction,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _terminalGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _terminalGreen.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.keyboard_return, color: _terminalGreen, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
