import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/core/widgets/scout_cyber_background.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class SpecialMissionsPage extends StatelessWidget {
  const SpecialMissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScoutCyberBackground(
      title: "MISI & FITUR",
      showBackArrow: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. DAFTAR SKU - Warna Kuning Penegak (Identitas Utama)
          _buildMissionCard(
            context,
            title: "DAFTAR SYARAT SKU",
            subtitle: "Cek kelengkapan syarat Bantara/Laksana",
            icon: Icons.checklist_rtl_rounded,
            iconColor: AppColors.scoutDarkBrown, // Ikon Coklat di atas Kuning
            bgColor: AppColors.penegakYellow, // Background Kuning
            textColor: AppColors.pitchBlack,
            onTap: () => Navigator.pushNamed(context, AppRoutes.skuMap),
          ),

          const SizedBox(height: 16),

          // 2. SKK & BADGES - Warna Merah Hasduk (Semangat)
          _buildMissionCard(
            context,
            title: "UJIAN SKK & BADGES",
            subtitle: "Dapatkan Tanda Kecakapan Khusus.",
            icon: Icons.military_tech_outlined,
            iconColor: AppColors.hasdukWhite,
            bgColor: AppColors.hasdukRed,
            textColor: AppColors.hasdukWhite,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fitur SKK Segera Hadir! 🛠️"),
                  backgroundColor: AppColors.hasdukRed,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 3. CYBER SCOUT - Warna Hitam Pekat (Digital/Security)
          _buildMissionCard(
            context,
            title: "CYBER SCOUT",
            subtitle: "Keamanan digital & sandi modern.",
            icon: Icons.security,
            iconColor: AppColors.penegakYellow, // Kuning menyala di atas Hitam
            bgColor: AppColors.pitchBlack,
            textColor: AppColors.hasdukWhite,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.cyberMissionControl),
          ),

          const SizedBox(height: 16),

          // 4. SURVIVAL - Warna Coklat Tua (Rimba)
          _buildMissionCard(
            context,
            title: "SURVIVAL & NAVIGASI",
            subtitle: "Panduan rimba & peta offline.",
            icon: Icons.forest_outlined,
            iconColor: AppColors.scoutLightBrown,
            bgColor: AppColors.scoutDarkBrown,
            textColor: AppColors.hasdukWhite,
            onTap: () => Navigator.pushNamed(context, AppRoutes.survivalTools),
          ),
        ],
      ),
    );
  }

  // Custom Card Builder agar warna bisa dikontrol penuh
  Widget _buildMissionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.pitchBlack.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1), // Transparan halus
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: iconColor, size: 16),
          ],
        ),
      ),
    );
  }
}
