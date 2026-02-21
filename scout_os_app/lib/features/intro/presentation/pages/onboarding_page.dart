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
      backgroundColor: const Color(0xFFE5E5E5), // Light background for contrast
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [_TriSatyaSlide(), _DasaDarmaSlide()],
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
        context.read<IntroController>().completeOnboarding(context);
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
// TRI SATYA SLIDE (Flat 3D Cards)
// ==========================================
class _TriSatyaSlide extends StatelessWidget {
  const _TriSatyaSlide();

  void _showExplanation(
    BuildContext context,
    String title,
    String explanation,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ExplanationSheet(title: title, explanation: explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deepBrown = Color(0xFF3E2723);

    return Container(
      color: const Color(0xFFF5F5DC), // Bone White
      child: Stack(
        children: [
          // Background Icon
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Center(
                child: Icon(
                  Icons.back_hand_rounded,
                  size: 280,
                  color: deepBrown,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "TRI SATYA",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      color: deepBrown,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Demi kehormatanku, aku berjanji akan bersungguh-sungguh:",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      color: deepBrown.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Interactive Cards
                  _TriSatyaCard(
                    number: "1",
                    text:
                        "Menjalankan kewajibanku terhadap Tuhan, NKRI, dan mengamalkan Pancasila.",
                    onTap: () => _showExplanation(
                      context,
                      "Kewajiban Utama",
                      "Seorang Pramuka harus taat beribadah sesuai agama dan setia menjaga keutuhan Negara Kesatuan Republik Indonesia.",
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TriSatyaCard(
                    number: "2",
                    text:
                        "Menolong sesama hidup dan ikut serta membangun masyarakat.",
                    onTap: () => _showExplanation(
                      context,
                      "Kepedulian Sosial",
                      "Pramuka selalu siap menolong orang lain tanpa membedakan dan aktif berkontribusi dalam kemajuan lingkungan.",
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TriSatyaCard(
                    number: "3",
                    text: "Menepati Dasa Darma.",
                    onTap: () => _showExplanation(
                      context,
                      "Kode Kehormatan",
                      "Menjadikan 10 janji Dasa Darma sebagai pedoman moral dalam berpikir, berkata, dan bertindak.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriSatyaCard extends StatelessWidget {
  final String number;
  final String text;
  final VoidCallback onTap;

  const _TriSatyaCard({
    required this.number,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F7FA), // Light Blue tint
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: const Color(0xFF0277BD),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DASA DARMA SLIDE (Scrollable Cards)
// ==========================================
class _DasaDarmaSlide extends StatelessWidget {
  const _DasaDarmaSlide();

  void _showExplanation(BuildContext context, int index, String title) {
    final explanations = [
      "Beribadah sesuai agama kepercayaan masing-masing.",
      "Menjaga lingkungan dan menyayangi sesama makhluk hidup.",
      "Sopan, santun, dan berjiwa ksatria dalam membela kebenaran.",
      "Menghargai pendapat orang lain dan mengutamakan diskusi.",
      "Siap membantu orang yang kesusahan dan tabah menghadapi cobaan.",
      "Selalu semangat, kreatif, dan tidak mudah putus asa.",
      "Menggunakan waktu dan harta secukupnya, tidak boros.",
      "Taat aturan, berani karena benar, dan setia pada janji.",
      "Selalu menjalankan tugas dengan sepenuh hati.",
      "Jujur dan bersih dalam niat, ucapan, dan perilaku.",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ExplanationSheet(title: title, explanation: explanations[index - 1]),
    );
  }

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
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.verified_user_rounded,
                size: 300,
                color: scoutGold,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                "DASA DARMA",
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  color: scoutGold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ketuk poin untuk melihat makna",
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  itemCount: points.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final num = index + 1;
                    return _DasaItemCard(
                          index: num,
                          text: points[index],
                          onTap: () =>
                              _showExplanation(context, num, points[index]),
                        )
                        .animate(delay: (index * 50).ms)
                        .fadeIn(duration: 300.ms)
                        .moveX(begin: 20, end: 0);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DasaItemCard extends StatelessWidget {
  const _DasaItemCard({
    required this.index,
    required this.text,
    required this.onTap,
  });

  final int index;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4), // 3D Lip
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF8D6E63), // Brown tint
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "$index",
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.fredoka(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black26,
            ),
          ],
        ),
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
