import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class MissionDashboardPage extends StatelessWidget {
  const MissionDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TopographyPainter(),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _HeaderSection(),
                const SizedBox(height: 20),
                _SkuCard(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.skuMap),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SurvivalCard(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.survivalTools,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SkkCard(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur SKK segera hadir.'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CyberCard(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.cyberMissionControl,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pusat Misi',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Siap untuk petualangan hari ini, Kak Rafiq?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _SkuCard extends StatelessWidget {
  const _SkuCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mission_sku',
      child: _BentoCard(
        onTap: onTap,
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jalur Penegak Bantara',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '12/24 Poin Selesai',
              style: GoogleFonts.poppins(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: 12 / 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD600)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: const Color(0xFF1B5E20),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: onTap,
              child: const Text('Lanjutkan Misi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurvivalCard extends StatelessWidget {
  const _SurvivalCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mission_survival',
      child: _BentoCard(
        onTap: onTap,
        border: Border.all(color: const Color(0xFF2E7D32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Survival Tools',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.explore, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Icon(Icons.gps_fixed, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Icon(Icons.terrain, color: Color(0xFF2E7D32)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '6 Tools Ready',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkkCard extends StatelessWidget {
  const _SkkCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mission_skk',
      child: _BentoCard(
        onTap: onTap,
        backgroundColor: const Color(0xFFFFD600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Koleksi TKK',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _badgeDot(),
                const SizedBox(width: 8),
                _badgeDot(),
                const SizedBox(width: 8),
                _badgeDot(),
              ],
            ),
            const Spacer(),
            Text(
              'Side Quest',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeDot() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      child: const Icon(Icons.star, size: 14, color: Color(0xFF1B5E20)),
    );
  }
}

class _CyberCard extends StatelessWidget {
  const _CyberCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mission_cyber',
      child: _BentoCard(
        onTap: onTap,
        backgroundColor: const Color(0xFF1B3A2E),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  painter: _CodePatternPainter(),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cyber Intelligence',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keamanan Digital & Sandi',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Icon(Icons.code, color: Color(0xFFFFD600)),
                    SizedBox(width: 8),
                    Icon(Icons.security, color: Color(0xFFFFD600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.child,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.gradient,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(16),
        height: 170,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _TopographyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = 20; y < size.height; y += 40) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 60) {
        path.quadraticBezierTo(
          x + 20,
          y + (x % 120 == 0 ? 8 : -8),
          x + 60,
          y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CodePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
