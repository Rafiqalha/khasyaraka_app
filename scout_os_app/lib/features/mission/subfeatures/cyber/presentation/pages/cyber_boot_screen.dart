import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class CyberBootScreen extends StatefulWidget {
  const CyberBootScreen({super.key});

  @override
  State<CyberBootScreen> createState() => _CyberBootScreenState();
}

class _CyberBootScreenState extends State<CyberBootScreen>
    with TickerProviderStateMixin {
  // Navigation Timer
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    // Simulate 4.5 seconds loading before navigation
    _navTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.cyberDashboard);
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Blue
      body: Stack(
        children: [
          // Background Gradient (Subtle)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // 1. Centerpiece: Breathing Icon
                const BreathingCenterpiece(),
                
                const Spacer(),
                
                // 2. Loading Title
                Text(
                  "Membangun Jalur Data...",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 3. Rotating Subtitle
                const RotatingSubtitle(),
                
                const SizedBox(height: 40),
                
                // 4. Custom Bouncing Indicator
                const BouncingDataBlocks(),
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: Breathing Centerpiece
// ---------------------------------------------------------------------------
class BreathingCenterpiece extends StatefulWidget {
  const BreathingCenterpiece({super.key});

  @override
  State<BreathingCenterpiece> createState() => _BreathingCenterpieceState();
}

class _BreathingCenterpieceState extends State<BreathingCenterpiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1CB0F6), Color(0xFF9333EA)], // Blue to Purple
          ),
          boxShadow: [
            // 3D Bottom Border Effect
            BoxShadow(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.5), // Using withValues as standard
              offset: const Offset(0, 10),
              blurRadius: 0,
            ),
            // Glow Effect
            BoxShadow(
              color: const Color(0xFF1CB0F6).withValues(alpha: 0.4),
              offset: const Offset(0, 0),
              blurRadius: 30,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2), 
            width: 4,
          ),
        ),
        child: const Icon(
          Icons.satellite_alt,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: Rotating Subtitle
// ---------------------------------------------------------------------------
class RotatingSubtitle extends StatefulWidget {
  const RotatingSubtitle({super.key});

  @override
  State<RotatingSubtitle> createState() => _RotatingSubtitleState();
}

class _RotatingSubtitleState extends State<RotatingSubtitle> {
  final List<String> _subtitles = [
    "Mengenkripsi sinyal...",
    "Mencari satelit terdekat...",
    "Menyiapkan protokol sandi...",
    "Verifikasi identitas agen...",
    "Mengunduh paket misi...",
  ];
  
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _subtitles.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Fixed height to prevent jumps
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _subtitles[_index],
          key: ValueKey<int>(_index),
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF22D3EE), // Cyan/Neon Blue
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: Bouncing Data Blocks
// ---------------------------------------------------------------------------
class BouncingDataBlocks extends StatefulWidget {
  const BouncingDataBlocks({super.key});

  @override
  State<BouncingDataBlocks> createState() => _BouncingDataBlocksState();
}

class _BouncingDataBlocksState extends State<BouncingDataBlocks>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBlock(0, const Color(0xFF4ADE80)), // Neon Green
        const SizedBox(width: 12),
        _buildBlock(1, const Color(0xFF1CB0F6)), // Neon Blue
        const SizedBox(width: 12),
        _buildBlock(2, const Color(0xFFA855F7)), // Neon Purple
      ],
    );
  }

  Widget _buildBlock(int index, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Staggered sine wave animation
        // Offset phase by index
        double t = (_controller.value + (index * 0.2)) % 1.0;
        
        
        // Correct bounce math: Parabola peaking at 0.25
        double val = 0;
        double st = _controller.value - (index * 0.15); // Stagger
        if (st < 0) st += 1.0;
        
        // Bounce happens in the first 50% of the staggered cycle
        if (st < 0.5) {
           // Map st (0..0.5) to x (-1..1)
           // st=0 -> x=-1 (Start)
           // st=0.25 -> x=0 (Peak)
           // st=0.5 -> x=1 (End)
           double x = (st * 4.0) - 1.0;
           val = -20.0 * (1.0 - x * x); 
        }

        return Transform.translate(
          offset: Offset(0, val),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                 BoxShadow(
                   color: color.withValues(alpha: 0.5),
                   blurRadius: 8,
                   offset: const Offset(0, 2),
                 )
              ],
            ),
          ),
        );
      },
    );
  }
}
