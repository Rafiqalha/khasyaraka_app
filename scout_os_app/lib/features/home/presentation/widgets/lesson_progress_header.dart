import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class LessonProgressHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final int current;
  final int total;
  final int userHearts;
  final int maxHearts;
  final VoidCallback onExit;

  const LessonProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.userHearts,
    required this.maxHearts,
    required this.onExit,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final segments = 10;
    final filled = total == 0 ? 0 : ((current / total) * segments).ceil();
    final pingMs = (DateTime.now().millisecondsSinceEpoch % 40) + 25;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textGrey, size: 28),
        onPressed: onExit,
        tooltip: "Exit",
      ),
      titleSpacing: 8,
      title: Row(
        children: [
          Text('SYS.HP', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8B949E), fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 12,
              child: Row(
                children: List.generate(segments, (i) {
                  final active = i < filled;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: i > 0 ? 3 : 0),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF3FB950) : const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: active ? const Color(0xFF3FB950) : const Color(0xFF30363D), width: 0.5),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sensors, size: 14, color: Color(0xFF3FB950)),
                const SizedBox(width: 6),
                Text(
                  'PING ${pingMs}ms',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF3FB950),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
