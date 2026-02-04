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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [
              _TriSatyaSlide(),
              _DasaDarmaSlide(),
            ],
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        context.read<IntroController>().completeOnboarding(context);
                      },
                      child: Text(
                        "SIAP SEDIA",
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .move(begin: const Offset(0, 12), end: Offset.zero),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TriSatyaSlide extends StatelessWidget {
  const _TriSatyaSlide();

  @override
  Widget build(BuildContext context) {
    const deepBrown = Color(0xFF3E2723);
    const boneWhite = Color(0xFFF5F5DC);

    final points = [
      "Demi kehormatanku, aku berjanji akan bersungguh-sungguh: menjalankan kewajibanku terhadap Tuhan, Negara Kesatuan Republik Indonesia dan mengamalkan Pancasila.",
      "Menolong sesama hidup dan mempersiapkan diri membangun masyarakat.",
      "Menepati Dasa Darma.",
    ];

    return Container(
      color: boneWhite,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Center(
                child: Icon(
                  Icons.back_hand_outlined,
                  size: 240,
                  color: deepBrown,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "TRI SATYA",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    color: deepBrown,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 28),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < points.length; i++) ...[
                        Text(
                          "${i + 1}. ${points[i]}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: deepBrown,
                            height: 1.5,
                          ),
                        ),
                        if (i != points.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  "Janji ini adalah fondasi karakter Penegak.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: deepBrown.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DasaDarmaSlide extends StatelessWidget {
  const _DasaDarmaSlide();

  @override
  Widget build(BuildContext context) {
    const deepBrown = Color(0xFF3E2723);
    const scoutGold = Color(0xFFFFD600);

    final points = [
      "Taqwa kepada Tuhan Yang Maha Esa",
      "Cinta alam dan kasih sayang sesama manusia",
      "Patriot yang sopan dan ksatria",
      "Patuh dan suka bermusyawarah",
      "Rela menolong dan tabah",
      "Rajin, terampil, dan gembira",
      "Hemat, cermat, dan bersahaja",
      "Disiplin, berani, dan setia",
      "Bertanggung jawab dan dapat dipercaya",
      "Suci dalam pikiran, perkataan, dan perbuatan",
    ];

    return Container(
      color: deepBrown,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "DASA DARMA",
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                color: scoutGold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: points.length,
                itemBuilder: (context, index) {
                  return _DasaItem(index: index + 1, text: points[index])
                      .animate(delay: (index * 120).ms)
                      .fadeIn(duration: 400.ms)
                      .move(begin: const Offset(0, 12), end: Offset.zero);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DasaItem extends StatelessWidget {
  const _DasaItem({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    const scoutGold = Color(0xFFFFD600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: scoutGold,
            child: Text(
              "$index",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
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
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFD600) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD600), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
