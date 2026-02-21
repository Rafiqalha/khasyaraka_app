import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isLocked ? Colors.grey.shade300 : Colors.white;
    final Color borderColor = isLocked
        ? Colors.grey.shade400
        : AppColors.textGrey.withValues(alpha: 0.2);
    final Color iconBg = isLocked
        ? Colors.grey.shade400
        : (isCompleted ? AppColors.goldBadge : AppColors.wosmPurple);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          // Efek 3D Bawah
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                isLocked ? Icons.lock : (isCompleted ? Icons.check : icon),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Colors.grey : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            if (!isLocked)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.scoutBrown,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
