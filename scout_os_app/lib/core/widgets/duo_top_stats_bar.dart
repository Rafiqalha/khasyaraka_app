import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DuoTopStatsBar extends StatelessWidget implements PreferredSizeWidget {
  final int streak;
  final int gems;
  final int hearts;

  const DuoTopStatsBar({
    super.key,
    this.streak = 0,
    this.gems = 0,
    this.hearts = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('assets/icons/stats/streak_fire.png', streak.toString(), const Color(0xFFFF9600)),
          _buildStatItem('assets/icons/stats/gem.png', gems.toString(), const Color(0xFF1CB0F6)),
          _buildStatItem('assets/icons/stats/heart.png', hearts.toString(), const Color(0xFFFF4B4B)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String iconPath, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Using a fallback emoji if asset doesn't exist, but we will assume assets exist or use emoji
        // Wait, Duolingo style uses icons. I'll use emoji fallback if the icon image is not found, or just standard Flutter icons.
        // Actually, we can just use text emojis for simplicity and guarantee it renders correctly without assets:
        Text(
          iconPath.contains('fire') ? '🔥' : iconPath.contains('gem') ? '💎' : '❤️',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // approximate height excluding safe area
}
