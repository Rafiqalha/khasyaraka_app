import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

class JamnasConstructionScreen extends StatelessWidget {
  const JamnasConstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Deep Blue
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // 1. Glowing Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3D00).withOpacity(0.4),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.landscape_rounded,
                      size: 140,
                      color: Color(0xFFFF3D00), // Orange Red
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 2. Typography (High Stakes)
                Text(
                  'Gerbang Cakrawala\nSedang Ditempa ⚜️',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 24, // User requested 22-24
                    height: 1.2,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Seutas tali sedang dipintal, sebuah janji sedang ditepati. Kami tengah merakit jalan setapak menuju puncak persaudaraan tertinggi di Jamnas XII.\n\nMohon bersabar sejenak, Kak. Biarkan kami menyempurnakan bekal ini, agar kelak ia siap menjadi kompas sejatimu.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFEEEEEE), // White/Light Grey
                      height: 1.6,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),

                // 3. Intense 3D Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD84315), // Oranye Bata
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD84315).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: const Border(
                        bottom: BorderSide(
                          color: Color(0xFFBF360C), // Darker Shade
                          width: 6.0, // 3D Effect
                        ),
                      ),
                    ),
                    child: Text(
                      'SAYA SETIA MENANTI',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
