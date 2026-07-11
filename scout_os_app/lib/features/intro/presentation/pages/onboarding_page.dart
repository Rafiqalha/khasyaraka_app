import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/intro/logic/intro_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [_LogoSlide(), _PradigiSlide()],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 42,
            child: Column(
              children: [
                _DotsIndicator(activeIndex: _currentIndex),
                const SizedBox(height: 20),
                if (_currentIndex == 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStartButton(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child:
          Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600), // Scout Gold Face
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF9A825), // Darker Gold Lip
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "SIAP SEDIA",
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .move(begin: const Offset(0, 12), end: Offset.zero),
    );
  }
}

// ==========================================
// FIRST SLIDE: Pigi Logo
// ==========================================
class _LogoSlide extends StatelessWidget {
  const _LogoSlide();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Center(
        child: Image.asset(
          'assets/images/logo/foreground-pigi.png',
          width: 250,
          height: 250,
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }
}

// ==========================================
// SECOND SLIDE: Pradigi Text
// ==========================================
class _PradigiSlide extends StatelessWidget {
  const _PradigiSlide();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Center(
        child: Text(
          "pradigi",
          style: GoogleFonts.fredoka(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2196F3), // Blue
            letterSpacing: 2.0,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFD600) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFF9A825), // Lip
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// Reusable Explanation Sheet
class _ExplanationSheet extends StatelessWidget {
  final String title;
  final String explanation;

  const _ExplanationSheet({required this.title, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02), // Duolingo Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ).copyWith(
                  // Custom Shadow for 3D effect could be done with Container instead
                ),
            child: Text(
              "MENGERTI",
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
