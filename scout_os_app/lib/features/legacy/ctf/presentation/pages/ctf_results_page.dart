import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/ctf/data/repositories/ctf_repository.dart';
import 'package:scout_os_app/features/ctf/data/models/ctf_models.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class CtfResultsPage extends StatefulWidget {
  final int roomId;
  final int myTeamId;

  const CtfResultsPage({
    super.key,
    required this.roomId,
    required this.myTeamId,
  });

  @override
  State<CtfResultsPage> createState() => _CtfResultsPageState();
}

class _CtfResultsPageState extends State<CtfResultsPage> {
  final CTFRepository _repo = CTFRepository();
  bool _isLoading = true;
  List<CTFTeam> _finalScores = [];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final scores = await _repo.getFinalScores(widget.roomId);
      if (mounted) {
        setState(() {
          _finalScores = scores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF9600))),
      );
    }

    if (_finalScores.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: Text('Data tidak ditemukan', style: TextStyle(color: Colors.black87))),
      );
    }

    final isWinner = _finalScores.first.teamId == widget.myTeamId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'HASIL AKHIR CTF',
          style: GoogleFonts.fredoka(color: const Color(0xFFFF9600), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isWinner ? Icons.emoji_events : Icons.verified_user,
              size: 100,
              color: isWinner ? const Color(0xFFFF9600) : Colors.blueGrey,
            ),
            const SizedBox(height: 16),
            Text(
              isWinner ? 'VICTORY!' : 'NICE TRY!',
              style: GoogleFonts.fredoka(
                color: isWinner ? const Color(0xFFFF9600) : Colors.black87,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            
            // Teams list
            ..._finalScores.asMap().entries.map((e) {
              final idx = e.key;
              final team = e.value;
              final isMe = team.teamId == widget.myTeamId;
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFFF9600).withValues(alpha: 0.1) : Colors.white,
                  border: Border.all(color: isMe ? const Color(0xFFFF9600) : const Color(0xFFE5E5E5), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${idx + 1}',
                          style: GoogleFonts.fredoka(
                            color: idx == 0 ? const Color(0xFFFF9600) : Colors.grey,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'Tim Kamu' : 'Lawan',
                              style: GoogleFonts.nunito(color: isMe ? const Color(0xFFFF9600) : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            if (team.flagFound)
                              Text('Flag Diretas 🚨', style: GoogleFonts.nunito(color: const Color(0xFFFF4B4B), fontSize: 12, fontWeight: FontWeight.bold))
                            else
                              Text('Pertahanan Sukses 🛡️', style: GoogleFonts.nunito(color: const Color(0xFF58CC02), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${team.score} pts',
                      style: GoogleFonts.fredoka(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 48),
            DuoButton(
              text: 'BAGIKAN HASIL',
              icon: Icons.share,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur share akan segera hadir!')),
                );
              },
              variant: DuoButtonVariant.outline,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('KEMBALI KE BERANDA', style: GoogleFonts.nunito(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
