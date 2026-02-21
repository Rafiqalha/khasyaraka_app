import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'package:flutter/material.dart';
import 'package:scout_os_app/core/widgets/realistic_fire_icon.dart';
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
        final hearts = controller.userHearts; // REMOVED: bonusHearts
        final isLoading = controller.isLoading;

        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Refresh Button
              _buildRefreshButton(context, controller, isLoading),

              // Fire / Streak 🔥
              _buildStatItem(
                context,
                customIcon: RealisticFireIcon(size: 28, isActive: streak > 0),
                color: streak > 0 ? Colors.orange : Colors.grey,
                text: '$streak',
              ),

              // XP ⭐
              _buildStatItem(
                context,
                customIcon: Image.asset(
                  'assets/icons/training/star.png',
                  height: 28,
                  width: 28,
                ),
                color: const Color(0xFFFFD700),
                text: '$xp',
              ),

              // Hearts / Lives ❤️
              _buildStatItem(
                context,
                customIcon: Image.asset(
                  'assets/icons/training/heart.png',
                  height: 28,
                  width: 28,
                  color: hearts > 0 ? null : Colors.grey,
                  colorBlendMode: hearts > 0 ? null : BlendMode.srcIn,
                ),
                color: hearts > 0 ? Colors.red : Colors.grey,
                text: hearts < controller.maxHearts ? '$hearts+' : '$hearts',
                onTap: () => _showAdDialog(context, controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefreshButton(
    BuildContext context,
    TrainingController controller,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              debugPrint('🔄 [REFRESH] Manual refresh triggered by user');

              // 1. Show Loading Overlay
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: Colors.black87,
                builder: (context) => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GrassSosLoader(),
                      SizedBox(height: 24),
                      Text(
                        "MEMPERBARUI DATA...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                ),
              );

              // 2. Perform Data Fetching
              await Future.wait([
                controller.loadProgress(),
                controller.loadUserStats(forceRefresh: true),
              ]);

              // 3. Dismiss Loading Overlay
              if (context.mounted) {
                Navigator.pop(context); // Close loading dialog
              }

              // 4. Show Success Premium Dialog
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2640),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF58CC02).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 24, bottom: 20),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C3558),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF58CC02),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF58CC02,
                                        ).withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Siap Melanjutkan!',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            child: Column(
                              children: [
                                Text(
                                  'Data pencapaian dan petualanganmu berhasil disinkronisasi.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF46A302),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF58CC02),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Lanjutkan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            letterSpacing: 1.0,
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
            },
      child: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 28),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    IconData? icon,
    Widget? customIcon,
    required Color color,
    String? text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customIcon != null)
            customIcon
          else if (icon != null)
            Icon(icon, color: color, size: 28),
          if (text != null) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTextStyles.h3.copyWith(color: color, fontSize: 16),
            ),
          ],
        ],
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
            color: const Color(0xFF1E2640), // Darker slate card background
            borderRadius: BorderRadius.circular(28),
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
                  color: const Color(
                    0xFF2C3558,
                  ), // Slightly lighter top section
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: Column(
                  children: [
                    // 3D Heart Icon Container
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C), // Deep Red Lip
                        borderRadius: BorderRadius.circular(24),
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
                          color: const Color(0xFFFF4B4B), // Bright Red Face
                          borderRadius: BorderRadius.circular(24),
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
                          color: const Color(0xFF2C3558), // Dark Blue-Grey Lip
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38446E), // Blue-Grey Face
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
