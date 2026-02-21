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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure minimum 3-second delay for branding visibility before checking auth state
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.read<IntroController>().checkAppState(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Background: Light Khaki / Tan (Warm, Flat Color)
    const backgroundColor = Color(0xFFF0EAD6); // Eggshell / Light Khaki

    // 2. Brand Color: Vibrant Purple (Duolingo Style)
    const brandColor = Color(0xFF562F00); // Purple

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon: Vibrant Purple (or Original PNG)
            Image.asset(
                  'assets/images/icon-khasyaraka.png',
                  width:
                      MediaQuery.of(context).size.width *
                      0.65, // Responsive Width
                  fit: BoxFit.contain,
                  // color: brandColor, // Removed color filter to show original PNG colors. Uncomment if tint is needed.
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 1200.ms,
                ),

            const SizedBox(height: 40),

            // Text Brand: "KHASYARAKA"
            Text(
                  "KHASYARAKA",
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
