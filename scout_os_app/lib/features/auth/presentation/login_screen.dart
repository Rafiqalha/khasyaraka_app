import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:scout_os_app/core/widgets/grass_sos_loader.dart';
import '../logic/login_controller.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _patternController;

  @override
  void initState() {
    super.initState();
    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Warna Utama: Light Khaki
    const backgroundColor = Color(0xFFF0EAD6);
    const brandPurple = Color(0xFF9C27B0); // Vibrant Purple WOSM

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 2. Background Pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _patternController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _patternController.value * 2 * math.pi,
                  child: const _ScoutPatternBackground(color: brandPurple),
                );
              },
            ),
          ),

          // Content Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Vertically Centered
                children: [
                  const Spacer(), // Push content to center
                  // Branding Text (No Logos)
                  Text(
                    "Salam Pramuka!",
                    style: GoogleFonts.fredoka(
                      fontSize: 36,
                      fontWeight: FontWeight.w700, // Bold
                      color: brandPurple,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Typewriter Animation
                  SizedBox(
                    height: 60, // Fixed height to prevent layout jump
                    child: DefaultTextStyle(
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            "Satyaku Kudharmakan,\nDharmaku Kubaktikan.",
                            textAlign: TextAlign.center,
                            speed: const Duration(milliseconds: 100),
                            cursor: '|',
                          ),
                        ],
                        isRepeatingAnimation: false, // Play once
                        displayFullTextOnTap: true,
                        totalRepeatCount: 1,
                      ),
                    ),
                  ),

                  const Spacer(), // Space between Hero and Button
                  // 4. Tombol Login Google (Bottom Positioned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: _ThreeDGoogleButton(
                      onPressed: () {
                        context.read<LoginController>().loginWithGoogle(
                          context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay (New SOS Loader)
          Consumer<LoginController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GrassSosLoader(),
                        const SizedBox(height: 24),
                        Text(
                          "MENGHUBUNGKAN...",
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _ScoutPatternBackground extends StatelessWidget {
  final Color color;

  const _ScoutPatternBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 40,
        crossAxisSpacing: 40,
      ),
      itemBuilder: (context, index) {
        final icons = [
          Icons.local_fire_department,
          Icons.explore,
          Icons.star,
          Icons.landscape,
          Icons.hiking,
          Icons.verified,
        ];
        final icon = icons[index % icons.length];

        // Random rotation for "scattered" look happens naturally via grid + index
        return Transform.rotate(
          angle: (index % 4) * (math.pi / 4), // 0, 45, 90, 135 deg rotation
          child: Icon(
            icon,
            color: color.withOpacity(0.05), // Low opacity
            size: 32,
          ),
        );
      },
    );
  }
}

class _ThreeDGoogleButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ThreeDGoogleButton({required this.onPressed});

  @override
  State<_ThreeDGoogleButton> createState() => _ThreeDGoogleButtonState();
}

class _ThreeDGoogleButtonState extends State<_ThreeDGoogleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 56,
        margin: EdgeInsets.only(top: _isPressed ? 5 : 0), // Push down effect
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: _isPressed
              ? [] // No shadow when pressed (flat)
              : [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 5), // 3D Bottom Border Effect
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/google/google.svg', height: 24),
            const SizedBox(width: 12),
            Text(
              "LANJUTKAN DENGAN GOOGLE",
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
