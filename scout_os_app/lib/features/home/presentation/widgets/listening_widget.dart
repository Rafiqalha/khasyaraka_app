import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class ListeningWidget extends StatefulWidget {
  final String audioUrl;

  const ListeningWidget({super.key, required this.audioUrl});

  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends State<ListeningWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (isPlaying) return;

    setState(() => isPlaying = true);
    try {
      await _player.play(UrlSource(widget.audioUrl));
      // Reset icon setelah selesai (simple timeout untuk contoh)
      // Idealnya pakai onPlayerComplete listener
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error playing audio: $e");
      }
    } finally {
      if (mounted) setState(() => isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _play,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.actionOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.actionOrange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.graphic_eq : Icons.volume_up_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Ketuk untuk mendengarkan",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
