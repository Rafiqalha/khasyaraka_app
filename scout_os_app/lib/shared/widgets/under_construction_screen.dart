import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for fonts if needed, though AppTextStyles usually handles it
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

enum ConstructionType {
  sku,
  skk,
  general,
}

class UnderConstructionScreen extends StatelessWidget {
  final ConstructionType type;

  const UnderConstructionScreen({
    super.key, 
    this.type = ConstructionType.general,
  });

  @override
  Widget build(BuildContext context) {
    // CONTENT LOGIC
    String title;
    String description;
    String buttonText;
    IconData icon;
    Color buttonColor;
    Color buttonShadowColor;

    switch (type) {
      case ConstructionType.sku:
        // VARIAN 1: SKU
        title = "Akar Pengabdian\nSedang Menghunjam Luas";
        description = "Setiap butir SKU adalah langkah kaki menuju kedewasaan. Kami sedang memahat peta perjalanan ini agar setiap tanda yang Kakak raih kelak bukan sekadar hiasan di lengan, melainkan bukti nyata keteguhan jiwa. Berilah kami waktu untuk menajamkan setiap maknanya.";
        buttonText = "SAYA SIAP BERPROSES";
        icon = Icons.forest_rounded;
        buttonColor = const Color(0xFF4B9F38); // Scout Green
        buttonShadowColor = const Color(0xFF1B5E20);
        break;

      case ConstructionType.skk:
        // VARIAN 2: SKK (Survival & Koleksi TKK)
        title = "Menajamkan Kapak,\nMenyiapkan Keahlian";
        description = "Seorang Pramuka dikenal dari kecakapannya merespons tantangan alam. Koleksi tanda kecakapan ini sedang kami asah agar siap Kakak gunakan saat terjun ke medan bakti yang sesungguhnya. Kesabaran adalah ujian pertama dari seorang ahli.";
        buttonText = "SAYA TERUS BERLATIH";
        icon = Icons.construction_rounded; // Or handyman
        buttonColor = const Color(0xFFFF9800); // Orange for Skills
        buttonShadowColor = const Color(0xFFE65100);
        break;

      case ConstructionType.general:
      default:
        // DEFAULT
        title = "Fitur Sedang Dirakit! 🚧";
        description = "Sabar ya Kak, Kakak Developer sedang lembur menyempurnakan materi ini biar makin eksklusif buat Kakak.";
        buttonText = "Oke, Saya Tunggu";
        icon = Icons.engineering_rounded;
        buttonColor = const Color(0xFF4B9F38);
        buttonShadowColor = const Color(0xFF1B5E20);
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Illustration (Icon in Circle)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 90,
                        color: buttonColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
          
                  // 2. Typography
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black54,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 48),
          
                  // 3. 3D Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          bottom: BorderSide(
                            color: buttonShadowColor, 
                            width: 6.0, // 3D Effect
                          ),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
