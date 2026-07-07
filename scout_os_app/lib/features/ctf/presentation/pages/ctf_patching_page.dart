import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/ctf/data/repositories/ctf_repository.dart';
import 'package:scout_os_app/features/ctf/data/models/ctf_models.dart';
import 'package:scout_os_app/features/ctf/presentation/pages/ctf_attack_page.dart';
import 'package:scout_os_app/features/ctf/presentation/pages/ctf_results_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class CtfPatchingPage extends StatefulWidget {
  final int roomId;
  final int myTeamId;

  const CtfPatchingPage({
    super.key,
    required this.roomId,
    required this.myTeamId,
  });

  @override
  State<CtfPatchingPage> createState() => _CtfPatchingPageState();
}

class _CtfPatchingPageState extends State<CtfPatchingPage> with SingleTickerProviderStateMixin {
  final CTFRepository _repo = CTFRepository();
  bool _isLoading = true;
  CTFStateResponse? _state;
  Timer? _pollingTimer;
  Timer? _countdownTimer;

  int _timeTakenSec = 0;
  int _timeLeft = 90;

  final TextEditingController _answerController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _colorAnimation = ColorTween(begin: const Color(0xFFFF4B4B), end: const Color(0xFFEA2B2B)).animate(_pulseController);

    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _answerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeTakenSec++;
          if (_timeLeft > 0) _timeLeft--;
        });
      }
    });
  }

  void _startPolling() {
    _pollState();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollState();
    });
  }

  Future<void> _pollState() async {
    try {
      final state = await _repo.getState(widget.roomId, widget.myTeamId);
      if (mounted) {
        setState(() {
          _state = state;
          _isLoading = false;
        });

        if (state.room.phase == 'attack' || state.room.phase == 'finished') {
          _navigateAway(state.room.phase);
        }
      }
    } catch (e) {
      // Ignored
    }
  }

  void _navigateAway(String phase) {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    if (phase == 'finished') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CtfResultsPage(roomId: widget.roomId, myTeamId: widget.myTeamId)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CtfAttackPage(roomId: widget.roomId, myTeamId: widget.myTeamId)),
      );
    }
  }

  Future<void> _submitPatch() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    try {
      final res = await _repo.submitPatch(widget.roomId, widget.myTeamId, text, _timeTakenSec);
      if (res['correct'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PATCH BERHASIL! 🛡️', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
        // Force poll to get updated state (attack or finished)
        _pollState();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jawaban salah! Coba lagi 🚨', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _state == null || _state!.patchChallenge == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4B4B))),
      );
    }

    final challenge = _state!.patchChallenge!;

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🚨 SISTEM DISERANG! 🚨',
                    style: GoogleFonts.fredoka(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flag kamu ditemukan! Patch sistem sekarang!',
                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _timeLeft / 90.0,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft > 60 ? const Color(0xFF58CC02) : _timeLeft > 30 ? const Color(0xFFFF9600) : Colors.yellow,
                          ),
                          strokeWidth: 8,
                        ),
                      ),
                      Text(
                        '$_timeLeft',
                        style: GoogleFonts.fredoka(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF1CB0F6), borderRadius: BorderRadius.circular(12)),
                              child: Text(challenge.challengeType.toUpperCase(), style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFF4B4B), borderRadius: BorderRadius.circular(12)),
                              child: Text(challenge.difficulty.toUpperCase(), style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          challenge.question,
                          style: GoogleFonts.fredoka(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _answerController,
                          style: GoogleFonts.nunito(color: Colors.black87, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF7F7F7),
                            hintText: 'Masukkan jawaban...',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                              borderSide: const BorderSide(color: Color(0xFFFF4B4B), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DuoButton(
                          text: 'PATCH SEKARANG!',
                          onPressed: _submitPatch,
                          variant: DuoButtonVariant.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('< 30 detik: +200 pts | < 60 detik: +150 pts', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('< 90 detik: +100 pts | > 90 detik: +50 pts', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
