import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/core/widgets/scout_cyber_background.dart';
import 'package:scout_os_app/core/widgets/xp_badge.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class LegacyHomePage extends StatelessWidget {
  const LegacyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isPremium = false; // Ganti logic ini nanti dengan Provider
    const String userName = "Kak Rafiq";
    const String userRank = "Calon Bantara";
    const int userXp = 1250;
    const int userStreak = 5;

    return ScoutCyberBackground(
      showBackArrow: false,
      // HEADER: Salam & Nama
      customTitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "SALAM PRAMUKA",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.scoutBrown.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.scoutBrown,
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. STATS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                XpBadge(xp: userXp, isLarge: true),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.actionOrange.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/training/fire.png',
                        width: 24,
                        height: 24,
                        color: AppColors.actionOrange,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$userStreak Hari",
                        style: const TextStyle(
                          color: AppColors.actionOrange,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. RANK CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.wosmPurple, const Color(0xFF4A148C)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.wosmPurple.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TINGKATAN SAAT INI",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userRank.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. MENU UTAMA (Hanya 1 Tombol Besar Sesuai Request)
            const Text(
              "MENU UTAMA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            _buildMainMenuCard(context, isPremium: isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuCard(BuildContext context, {required bool isPremium}) {
    final String title = isPremium ? "PETA PERJALANAN" : "BANK SOAL (LATIHAN)";
    final String subtitle = isPremium
        ? "Lanjutkan misi Bantara & Laksana"
        : "Latihan soal umum tanpa fitur kenaikan tingkat";
    final IconData icon = isPremium ? Icons.map_rounded : Icons.quiz_rounded;
    final Color color = isPremium ? AppColors.goldBadge : Colors.white;

    return GestureDetector(
      onTap: () {
        if (isPremium) {
          Navigator.pushNamed(context, AppRoutes.skuMap);
        } else {
          Navigator.pushNamed(context, AppRoutes.trainingMap);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.textGrey.withValues(alpha: 0.2),
            width: isPremium ? 0 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.scoutBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isPremium ? Colors.white : AppColors.scoutBrown,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "FREE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
