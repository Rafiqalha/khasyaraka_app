import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/arena/logic/arena_controller.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/core/config/feature_flags.dart';

class ArenaResultsPage extends StatefulWidget {
  const ArenaResultsPage({super.key});

  @override
  State<ArenaResultsPage> createState() => _ArenaResultsPageState();
}

class _ArenaResultsPageState extends State<ArenaResultsPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareVictoryCard() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/victory_card.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Kami baru saja menyelesaikan pertempuran Arena Cyber-Scout! 🚀 Ayo gabung Pradigi!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ArenaController>();
    final state = controller.currentState;

    if (state == null) {
      return const Scaffold(body: Center(child: Text('No results')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('HASIL AKHIR', style: GoogleFonts.fredoka(color: const Color(0xFFFF9600), fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors.white, // Ensure background is visible in screenshot
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 100, color: Color(0xFFFF9600)),
                      const SizedBox(height: 16),
                      Text(
                        'KOMPETISI SELESAI!',
                        style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Arena: ${controller.currentRoom?.code ?? "-"}',
                        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.leaderboard.length,
                          itemBuilder: (context, index) {
                            final team = state.leaderboard[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: index == 0 ? const Color(0xFFFF9600).withValues(alpha: 0.1) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: index == 0 ? const Color(0xFFFF9600) : const Color(0xFFE5E5E5), width: 2),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: index == 0 ? const Color(0xFFFF9600) : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${index + 1}', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                                title: Text(team.teamName, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
                                trailing: Text('${team.score} pts', style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.bold, color: index == 0 ? const Color(0xFFFF9600) : Colors.black87)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _isSharing
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF1CB0F6)))
                      : DuoButton(
                          text: 'BAGIKAN KE SOSMED',
                          icon: Icons.share,
                          onPressed: _shareVictoryCard,
                          variant: DuoButtonVariant.blue,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!FeatureFlags.enableTeamMode) ...[
              DuoButton(
                text: 'REMATCH VS HUMAN?',
                icon: Icons.refresh,
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                variant: DuoButtonVariant.blue,
              ),
              const SizedBox(height: 12),
            ],
            DuoButton(
              text: 'KEMBALI KE BERANDA',
              icon: Icons.home,
              onPressed: () {
                controller.leaveRoom();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              variant: FeatureFlags.enableTeamMode ? DuoButtonVariant.blue : DuoButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}
