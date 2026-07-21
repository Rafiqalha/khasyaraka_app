import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/arena/data/repositories/arena_repository.dart';
import 'package:scout_os_app/features/arena/logic/arena_controller.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_lobby_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ArenaMatchmakingPage extends StatefulWidget {
  const ArenaMatchmakingPage({super.key});

  @override
  State<ArenaMatchmakingPage> createState() => _ArenaMatchmakingPageState();
}

class _ArenaMatchmakingPageState extends State<ArenaMatchmakingPage> with SingleTickerProviderStateMixin {
  final ArenaRepository _repository = ArenaRepository();
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _secondsElapsed = 0;
  bool _isMatched = false;
  bool _showDifficultyOverlay = false;
  String _selectedDifficulty = 'Penggalang';
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startMatchmaking();
  }

  Future<void> _startMatchmaking() async {
    try {
      await _repository.matchmakeJoin();
      
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
              _secondsElapsed++;
              if (_secondsElapsed == 5) {
                _showDifficultyOverlay = true;
              }
              if (_secondsElapsed == 10) {
                _matchWithBot();
              }
        });
      });

      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (_isMatched || !mounted) return;
        try {
          final roomCode = await _repository.getMatchmakeStatus();
          if (roomCode != null && roomCode.isNotEmpty) {
            _onMatchFound(roomCode);
          }
        } catch (e) {
          // ignore network error
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai matchmaking: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _matchWithBot() async {
    _cleanupTimers();
    if (_isMatched) return;
    _isMatched = true;

    try {
      final roomCode = await _repository.createBotMatch(_selectedDifficulty);
      _onMatchFound(roomCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat bot match: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _onMatchFound(String roomCode) async {
    _cleanupTimers();
    if (!mounted) return;

    // We join the room using the controller
    final controller = ArenaController();
    await controller.joinRoom(roomCode);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: controller,
            child: const ArenaLobbyPage(),
          ),
        ),
      );
    }
  }

  void _cleanupTimers() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
  }

  Future<bool> _onWillPop() async {
    _cleanupTimers();
    if (!_isMatched) {
      try {
        await _repository.matchmakeCancel();
      } catch (_) {}
    }
    return true;
  }

  @override
  void dispose() {
    _radarController.dispose();
    _cleanupTimers();
    if (!_isMatched) {
      _repository.matchmakeCancel().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF131F24), // Dark background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'MENCARI LAWAN...',
            style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radar Effect
                      RotationTransition(
                        turns: _radarController,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF1CB0F6).withOpacity(0.1),
                                const Color(0xFF1CB0F6).withOpacity(0.5),
                                const Color(0xFF1CB0F6),
                              ],
                              stops: const [0.0, 0.5, 0.9, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1CB0F6).withOpacity(0.5), width: 2),
                        ),
                      ),
                      const Icon(Icons.search, size: 80, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '00:${_secondsElapsed.toString().padLeft(2, '0')}',
                    style: GoogleFonts.fredoka(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      'Estimasi Waktu: 00:10',
                    style: GoogleFonts.nunito(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            if (_showDifficultyOverlay)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Waktu hampir habis!',
                            style: GoogleFonts.fredoka(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kami akan mencarikan Bot untukmu. Pilih tingkat kesulitan:',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ...['Pemula', 'Penggalang', 'Penegak'].map((diff) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: DuoButton(
                              text: diff,
                              variant: _selectedDifficulty == diff ? DuoButtonVariant.blue : DuoButtonVariant.outline,
                              onPressed: () {
                                setState(() {
                                  _selectedDifficulty = diff;
                                });
                              },
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
