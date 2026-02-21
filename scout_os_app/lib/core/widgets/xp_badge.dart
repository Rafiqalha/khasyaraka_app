import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class XpBadge extends StatelessWidget {
  final int xp;
  final bool isLarge;

  const XpBadge({super.key, required this.xp, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldBadge.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldBadge.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/training/star.png',
            width: isLarge ? 24 : 18,
            height: isLarge ? 24 : 18,
          ),
          SizedBox(width: isLarge ? 8 : 4),
          Text(
            "$xp XP",
            style: TextStyle(
              color: AppColors.goldBadge,
              fontWeight: FontWeight.w900,
              fontSize: isLarge ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
