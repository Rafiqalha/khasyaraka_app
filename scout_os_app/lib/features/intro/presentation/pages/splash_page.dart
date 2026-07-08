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
  // Timer and initState removed as main.dart FutureBuilder handles routing

  @override
  Widget build(BuildContext context) {
    // 1. Background: Light Khaki / Tan (Warm, Flat Color)
    const backgroundColor = Color(0xFFF0EAD6); // Eggshell / Light Khaki

    // 2. Brand Color: Vibrant Purple (Duolingo Style)
    const brandColor = Color(0xFF562F00); // Pramuka Dark Brown

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 40),

            // Text Brand: "PRADIGI"
            Text(
                  "PRADIGI",
                  style: TextStyle(
                    fontFamily:
                        'Fredoka', // Using the local asset defined in pubspec.yaml
                    color: brandColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w600, // Matches SemiBold asset
                    letterSpacing: 2.0,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .moveY(begin: 10, end: 0, curve: Curves.easeOutQuad),
          ],
        ),
      ),
    );
  }
}
