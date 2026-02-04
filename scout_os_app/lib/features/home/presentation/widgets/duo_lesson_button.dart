import 'package:flutter/material.dart';
import '../../data/models/training_path.dart';

class DuoLessonButton extends StatelessWidget {
  final LessonNode lesson;
  final VoidCallback onTap;
  final bool isLocked;
  final Color color;

  const DuoLessonButton({
    super.key,
    required this.lesson,
    required this.onTap,
    required this.isLocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 75; 
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size + 8, 
            child: Stack(
              children: [
                // Layer Bayangan (Bawah)
                Positioned(
                  top: 6, 
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade400 : _darken(color),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Layer Utama (Atas)
                Positioned(
                  top: 0,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade300 : color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        // PERBAIKAN DEPRECATED: Ganti withOpacity jadi withValues
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isLocked ? Icons.lock : Icons.star,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Mahkota jika Completed
                if (lesson.status == 'completed')
                   Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 12,
                      child: Icon(Icons.check, size: 16, color: color),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _darken(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}