import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class PathCard extends StatelessWidget {
  final String title;
  final String description;
  final String difficulty; // "Easy", "Medium", "Hard"
  final VoidCallback onTap;

  const PathCard({
    super.key,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'hard': difficultyColor = AppColors.scoutRed; break;
      case 'medium': difficultyColor = AppColors.actionOrange; break;
      default: difficultyColor = AppColors.forestGreen;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.scoutBrown.withValues(alpha: 0.1), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.scoutBrown.withValues(alpha: 0.1),
              offset: const Offset(0, 6), // 3D Effect
              blurRadius: 0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image Placeholder (Bisa diganti Image.asset nanti)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Center(
                child: Icon(Icons.map_rounded, size: 40, color: difficultyColor),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900, 
                          color: AppColors.textDark
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficulty.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}