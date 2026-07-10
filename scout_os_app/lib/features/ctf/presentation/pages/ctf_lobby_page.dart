import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/ctf/data/repositories/ctf_repository.dart';
import 'package:scout_os_app/features/ctf/data/models/ctf_models.dart';
import 'package:scout_os_app/features/ctf/presentation/pages/ctf_defense_page.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class CtfLobbyPage extends StatefulWidget {
  final int roomId;
  final int myTeamId;
  final String roomCode;
  final bool isHost;

  const CtfLobbyPage({
    super.key,
    required this.roomId,
    required this.myTeamId,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<CtfLobbyPage> createState() => _CtfLobbyPageState();
}

class _CtfLobbyPageState extends State<CtfLobbyPage> {
  final CTFRepository _repo = CTFRepository();
  bool _isLoading = true;
  CTFStateResponse? _state;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initRoomAndPoll();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initRoomAndPoll() async {
    try {
      if (widget.isHost) {
        await _repo.initializeRoom(widget.roomId);
      }
      _startPolling();
    } catch (e) {
      // Ignored for demo simplicity, handle error in prod
      _startPolling();
    }
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

        if (state.room.phase == 'defense') {
          _pollingTimer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CtfDefensePage(
                roomId: widget.roomId,
                myTeamId: widget.myTeamId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Ignore polling errors
    }
  }

  Future<void> _startDefense() async {
    try {
      await _repo.startDefensePhase(widget.roomId);
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'CTF LOBBY',
          style: GoogleFonts.fredoka(color: const Color(0xFF58CC02), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF58CC02)))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text('ROOM CODE', style: GoogleFonts.fredoka(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          widget.roomCode,
                          style: GoogleFonts.fredoka(
                            color: const Color(0xFF1CB0F6),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security, color: Color(0xFF58CC02), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'MODE: CTF ATTACK-DEFENSE',
                          style: GoogleFonts.fredoka(color: const Color(0xFF58CC02), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildPhaseInstruction('1. DEFENSE (3 MENIT)', 'Sembunyikan flag di balik cipher & gambar budaya.'),
                        const SizedBox(height: 16),
                        _buildPhaseInstruction('2. ATTACK (5 MENIT)', 'Gunakan AI Cipher untuk retas flag lawan.'),
                        const SizedBox(height: 16),
                        _buildPhaseInstruction('3. PATCHING (DARURAT)', 'Jawab soal IT cepat saat sistemmu diretas!'),
                      ],
                    ),
                  ),
                  if (widget.isHost)
                    DuoButton(
                      text: 'MULAI DEFENSE PHASE',
                      onPressed: _startDefense,
                      variant: DuoButtonVariant.green,
                    )
                  else
                    Center(
                      child: Text(
                        'Menunggu Host memulai pertandingan...',
                        style: GoogleFonts.nunito(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPhaseInstruction(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1CB0F6), size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.fredoka(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
