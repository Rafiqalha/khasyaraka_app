import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/intro/logic/intro_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    // Ganti ke teks setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Background gelap sesuai aplikasi
    const backgroundColor = Color(0xFF16161A); // AppColors.graphite
    // Warna biru cyber
    const brandColor = Color(0xFF00F0FF); // AppColors.cyberBlue

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: !_showText
              ? // Scene 1: Logo Pigi
                Image.asset(
                  'assets/images/logo/foreground-pigi.png',
                  key: const ValueKey('logo'),
                  width: 250,
                  height: 250,
                )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
              : // Scene 2: Teks PRADIGI
                Text(
                  "pradigi",
                  key: const ValueKey('text'),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    color: brandColor,
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .moveY(begin: 10, end: 0, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }
}

