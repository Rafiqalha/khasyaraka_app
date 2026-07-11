import 'package:flutter/material.dart';
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
    double progress = total == 0 ? 0 : (current) / total; // Use current instead of current+1 for actual progress

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textGrey, size: 28),
        onPressed: onExit,
        tooltip: "Keluar Latihan",
      ),
      titleSpacing: 0,
      title: SizedBox(
        height: 18,
        child: Stack(
          children: [
            // Background Lip
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            // Background Face
            Container(
              height: 15,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Progress Lip
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF46A302), // Darker green lip
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            // Progress Face
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen, // 0xFF58CC02
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Progress Glint (Highlight)
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 5,
                margin: const EdgeInsets.only(top: 2, left: 6, right: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3D Heart Icon
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: const Color(0xFFCC3C3C), // Always active
                        size: 28,
                      ),
                    ),
                    Icon(
                      Icons.favorite_rounded,
                      color: const Color(0xFFFF4B4B), // Always active
                      size: 28,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2, right: 2),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white.withOpacity(0.2),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '∞', // Unlimited Hearts
                style: TextStyle(
                  color: const Color(0xFFFF4B4B), // Always active
                  fontSize: 22, // Slightly larger for infinity symbol
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
