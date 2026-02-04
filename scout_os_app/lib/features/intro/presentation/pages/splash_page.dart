import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
      context.read<IntroController>().checkAppState(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    const deepBrown = Color(0xFF3E2723);
    const scoutGold = Color(0xFFFFD600);

    return Scaffold(
      backgroundColor: deepBrown,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
                  .shimmer(
                    duration: 1200.ms,
                    color: scoutGold.withValues(alpha: 0.6),
                  ),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "KHASYARAKA",
                  style: GoogleFonts.cinzel(
                    color: scoutGold,
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 700.ms)
                    .move(begin: const Offset(0, 12), end: Offset.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
