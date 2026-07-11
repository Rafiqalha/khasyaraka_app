
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/home/data/models/training_course.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        final isLoading = controller.isLoading;

        return Container(
          color: AppColors.deepCharcoal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Rapatkan ke tengah
            children: [
              // 1. COURSE PICKER (REMOVED: Only one Cyber Scout course now)

              // 2. STREAK (Fire)
              _buildStatItem(
                context,
                iconWidget: _build3DIcon(
                  icon: FontAwesomeIcons.fire,
                  faceColor: streak > 0 ? AppColors.statFire : AppColors.lockedGrey,
                  lipColor: streak > 0 ? AppColors.statFireDark : AppColors.lockedGreyDark,
                  shadowColor: Colors.transparent,
                ),
                color: streak > 0 ? AppColors.statFire : AppColors.lockedGrey,
                text: '$streak',
              ),

              const SizedBox(width: 32), // Jarak yang dirapatkan

              // 3. XP (Star / Gems)
              _buildStatItem(
                context,
                iconWidget: _build3DIcon(
                  icon: FontAwesomeIcons.solidStar,
                  faceColor: AppColors.statStar,
                  lipColor: AppColors.statStarDark,
                  shadowColor: Colors.transparent,
                ),
                color: AppColors.statStar,
                text: '$xp',
              ),

              const SizedBox(width: 32), // Jarak yang dirapatkan

              // 4. HEARTS (Lives) - UNLIMITED FOR LAUNCH
              _buildStatItem(
                context,
                iconWidget: _build3DIcon(
                  icon: FontAwesomeIcons.solidHeart,
                  faceColor: AppColors.statHeart,
                  lipColor: AppColors.statHeartDark,
                  shadowColor: Colors.transparent,
                ),
                color: AppColors.statHeart,
                text: '∞', // Unlimited Hearts
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nyawa tidak terbatas selama masa peluncuran! 🚀'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DIcon({
    required dynamic icon,
    required Color faceColor,
    required Color lipColor,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          if (shadowColor != Colors.transparent)
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lip / Bottom Shadow (Slightly larger and shifted down)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: FaIcon(icon, color: lipColor, size: 28),
          ),
          // Face / Highlight
          FaIcon(icon, color: faceColor, size: 28),
          // Tiny glint/highlight using a slightly lighter color and offset up
          Padding(
            padding: const EdgeInsets.only(bottom: 2, right: 2),
            child: FaIcon(icon, color: Colors.white.withOpacity(0.2), size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required Widget iconWidget,
    required Color color,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.h3.copyWith(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdDialog(BuildContext context, TrainingController controller) {
    final isFull = controller.userHearts >= controller.maxHearts;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: AppColors.charcoalSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section with Heart Icon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 32, bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.deepCharcoal,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: Column(
                  children: [
                    // 3D Heart Icon Container
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.statHeartDark,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.statHeart,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          'assets/icons/training/heart.png',
                          height: 48,
                          width: 48,
                          color: isFull ? null : Colors.grey,
                          colorBlendMode: isFull ? null : BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isFull ? 'Nyawa Penuh!' : 'Kehabisan Nyawa?',
                      style: const TextStyle(
                        fontFamily:
                            'Fredoka', // Assuming Fredoka is available globally or fallback to default
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    Text(
                      isFull
                          ? 'Kamu sudah memiliki nyawa maksimal (${controller.userHearts}/${controller.maxHearts}).\nMainkan misi untuk menggunakannya!'
                          : 'Tonton iklan singkat untuk mendapatkan 1 nyawa tambahan dan lanjutkan petualanganmu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (!isFull) ...[
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/training/heart.png',
                              height: 18,
                              width: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Saat ini: ${controller.userHearts}/${controller.maxHearts}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3D Flat Primary Button (Watch Ad)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          controller.watchAdForHearts();
                        },
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF46A302), // Dark Green Lip
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF58CC02).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF58CC02), // Duolingo Green
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'TONTON IKLAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 3D Flat Secondary Button (Cancel / OK)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.scoutBrownDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.scoutBrown,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              isFull ? 'SAYA MENGERTI' : 'TIDAK, TERIMA KASIH',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
