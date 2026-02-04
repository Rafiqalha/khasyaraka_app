import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/logic/cyber_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/data/sandi_model.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/widgets/cyber_container.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/morse_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/rumput_tool_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kimia_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_ular_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_semaphore_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_angka_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_napoleon_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_an_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_az_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kotak1_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kotak2_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_jam_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_koordinat_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_and_page.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/pages/sandi_kotak3_page.dart';

/// Cyber Dashboard Screen
/// 
/// Displays 15 Sandi Pramuka tools in a futuristic grid layout.
class CyberDashboardScreen extends StatefulWidget {
  const CyberDashboardScreen({super.key});

  @override
  State<CyberDashboardScreen> createState() => _CyberDashboardScreenState();
}

class _CyberDashboardScreenState extends State<CyberDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load Sandi list on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CyberController>();
      controller.loadSandiList();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full black OLED
      appBar: AppBar(
        backgroundColor: Colors.black, // Full black OLED
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CYBER INTELLIGENCE',
          style: CyberTheme.headline().copyWith(
            fontSize: 18,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CyberController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return _buildLoadingState();
          }

          if (controller.errorMessage != null && controller.sandiList.isEmpty) {
            return _buildErrorState(controller);
          }

          if (controller.sandiList.isEmpty) {
            return _buildEmptyState();
          }

          return _buildGrid(controller.sandiList, controller);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CyberTheme.neonCyan),
          ),
          const SizedBox(height: 16),
          Text(
            'INITIALIZING...',
            style: CyberTheme.terminal(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CyberController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: CyberTheme.alertOrange,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ?? 'Error loading Sandi types',
              style: CyberTheme.body().copyWith(
                color: CyberTheme.alertOrange,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.loadSandiList(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'RETRY',
                style: CyberTheme.headline().copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: CyberTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'NO TOOLS AVAILABLE',
            style: CyberTheme.body().copyWith(
              color: CyberTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<SandiModel> sandiList, CyberController controller) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sandi = sandiList[index];
                return _SandiCard(
                  sandi: sandi,
                  index: index,
                  animationController: _animationController,
                  onTap: () {
                    controller.selectSandi(sandi);
                    final codename = sandi.codename.toLowerCase();
                    
                    // Navigate to appropriate tool page
                    if (codename == 'morse') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MorseToolPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'rumput') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RumputToolPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'kimia') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiKimiaPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'ular') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiUlarPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'semaphore') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiSemaphorePage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'angka') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiAngkaPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'napoleon') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiNapoleonPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'an') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiAnPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'az' || codename == 'az_atbash') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiAzPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'kotak_1' || codename == 'kotak1') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiKotak1Page(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'kotak_2' || codename == 'kotak2') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiKotak2Page(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'kotak_3' || codename == 'kotak3') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiKotak3Page(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'jam') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiJamPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'koordinat') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiKoordinatPage(sandi: sandi),
                        ),
                      );
                    } else if (codename == 'and') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SandiAndPage(sandi: sandi),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${sandi.name} Tool coming soon...',
                            style: CyberTheme.body().copyWith(color: Colors.white),
                          ),
                          backgroundColor: Colors.black.withOpacity(0.9),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              childCount: sandiList.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sandi Card Widget with Glassmorphism effect
class _SandiCard extends StatefulWidget {
  final SandiModel sandi;
  final int index;
  final AnimationController animationController;
  final VoidCallback onTap;

  const _SandiCard({
    required this.sandi,
    required this.index,
    required this.animationController,
    required this.onTap,
  });

  @override
  State<_SandiCard> createState() => _SandiCardState();
}

class _SandiCardState extends State<_SandiCard>
    with SingleTickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Staggered animation based on index
    final delay = widget.index * 0.05;

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          delay,
          delay + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          delay,
          delay + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animationController.forward();
    });
  }

  String _getCyberSecurityTerm() {
    final category = widget.sandi.category.toLowerCase();
    switch (category) {
      case 'encoding':
        return 'ENCODING PROTOCOL';
      case 'substitution':
        return 'SUBSTITUTION CIPHER';
      case 'transposition':
        return 'TRANSPOSITION CIPHER';
      case 'visual':
        return 'VISUAL CRYPTOGRAPHY';
      default:
        return 'CRYPTOGRAPHIC TOOL';
    }
  }

  Color _getCategoryColor() {
    final category = widget.sandi.category.toLowerCase();
    switch (category) {
      case 'encoding':
        return CyberTheme.matrixGreen;
      case 'substitution':
        return CyberTheme.neonCyan;
      case 'transposition':
        return CyberTheme.alertOrange;
      case 'visual':
        return Colors.purple.shade400;
      default:
        return CyberTheme.neonCyan;
    }
  }

  IconData _getSandiIcon() {
    final codename = widget.sandi.codename.toLowerCase();

    // Map codename to appropriate icon
    switch (codename) {
      case 'morse':
        return Icons.radio_button_checked;
      case 'semaphore':
        return Icons.flag;
      case 'rumput':
        return Icons.grass;
      case 'kimia':
        return Icons.science;
      case 'angka':
        return Icons.numbers;
      case 'an_rot13':
        return Icons.rotate_right;
      case 'az_atbash':
        return Icons.swap_horiz;
      case 'kotak_1':
      case 'kotak_2':
      case 'kotak_3':
        return Icons.grid_3x3;
      case 'jam':
        return Icons.access_time;
      case 'koordinat':
        return Icons.map;
      case 'and':
        return Icons.code;
      case 'ular':
        return Icons.waves;
      case 'napoleon':
        return Icons.military_tech;
      default:
        return Icons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.95 : 1.0),
            child: CyberContainer(
              child: Stack(
                children: [
                  // Grid Pattern Background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPatternPainter(
                        color: _getCategoryColor().withOpacity(0.1),
                      ),
                    ),
                  ),

                  // Scanline Effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _getCategoryColor().withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Corner Accents
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                          left: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                          right: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                          left: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                          right: BorderSide(
                            color: _getCategoryColor(),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center Icon with Glow
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getCategoryColor().withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getSandiIcon(),
                        size: 40,
                        color: _getCategoryColor(),
                      ),
                    ),
                  ),

                  // Bottom Section: Name and Category
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sandi Name
                          Text(
                            widget.sandi.name.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CyberTheme.textPrimary,
                              letterSpacing: 1.5,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Cyber Security Term
                          Text(
                            _getCyberSecurityTerm(),
                            style: GoogleFonts.courierPrime(
                              fontSize: 9,
                              color: _getCategoryColor(),
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Animated Pulse Effect
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getCategoryColor().withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grid Pattern Painter for futuristic background
class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 15) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
