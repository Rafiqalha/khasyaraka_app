import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class ScoutCyberBackground extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? customTitle;
  final bool showBackArrow;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ScoutCyberBackground({
    super.key,
    required this.child,
    this.title,
    this.customTitle,
    this.showBackArrow = true,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scoutBg, // Menggunakan Coklat Muda (Krem)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: showBackArrow
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.scoutBrown,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title:
            customTitle ??
            (title != null
                ? Text(
                    title!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.scoutBrown, // Coklat Tua
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  )
                : null),
        actions: actions,
      ),
      body: Stack(
        children: [
          // --- DEKORASI LATAR BELAKANG (Cyber Pattern) ---

          // 1. Lingkaran Dekorasi Atas Kanan (Ganti Ungu jadi Kuning Penegak)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.penegakYellow.withValues(
                    alpha: 0.2,
                  ), // Tidak pakai const
                  width: 2,
                ),
              ),
            ),
          ),

          // 2. Lingkaran Solid Kecil (Aksen Merah Hasduk)
          Positioned(
            top: 40,
            right: 80,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.hasdukRed.withValues(
                  alpha: 0.1,
                ), // Tidak pakai const
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. Garis-garis Cyber (Tech Lines) - Coklat Tua Pudar
          Positioned(
            top: 100,
            left: -20,
            child: Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.scoutBrown.withValues(
                  alpha: 0.05,
                ), // Tidak pakai const
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            top: 110,
            left: -10,
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.scoutBrown.withValues(
                  alpha: 0.05,
                ), // Tidak pakai const
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 4. Logo WOSM/Tunas Samar di tengah (Opsional/Watermark)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.03, // Sangat transparan
                child: Icon(
                  Icons.spa, // Simbol mirip Tunas Kelapa
                  size: 300,
                  color: AppColors.scoutBrown,
                ),
              ),
            ),
          ),

          // --- KONTEN UTAMA ---
          SafeArea(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
