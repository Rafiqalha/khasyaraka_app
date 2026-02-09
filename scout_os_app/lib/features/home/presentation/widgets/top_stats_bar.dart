import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';

/// TopStatsBar - Duolingo-style stats bar
/// 
/// Displays real user stats from backend:
/// - 🔥 Streak (daily login streak)
/// - ⭐ XP (experience points)
/// - ❤️ Hearts (lives remaining)
/// 
/// Consumes data from TrainingController via Provider.
class TopStatsBar extends StatelessWidget {
  const TopStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingController>(
      builder: (context, controller, child) {
        final streak = controller.userStreak;
        final xp = controller.userXp;
        final hearts = controller.userHearts;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flag / Course Icon
              _buildStatItem(
                icon: Icons.flag_rounded,
                color: Colors.grey,
                text: null,
              ),

              // Fire / Streak 🔥
              _buildStatItem(
                icon: Icons.local_fire_department_rounded,
                color: streak > 0 ? Colors.orange : Colors.grey,
                text: '$streak',
              ),

              // XP ⭐
              _buildStatItem(
                icon: Icons.star_rounded,
                color: const Color(0xFFFFD700),
                text: '$xp',
              ),

              // Hearts / Lives ❤️
              _buildStatItem(
                icon: Icons.favorite_rounded,
                color: hearts > 0 ? Colors.red : Colors.grey,
                text: '$hearts',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    String? text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        if (text != null) ...[
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}
