import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import 'package:scout_os_app/routes/app_routes.dart';
import 'package:scout_os_app/features/arena/presentation/pages/arena_home_page.dart';

class MissionDashboardPage extends StatelessWidget {
  const MissionDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AuthController for dynamic user data
    final user = context.watch<AuthController>().currentUser;
    final userName = user?.name ?? 'Pramuka'; // Fallback if name is null

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _TopographyPainter())),
            ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                90,
              ), // Bottom padding for navbar
              children: [
                _HeaderSection(userName: userName),
                const SizedBox(height: 24),
                _Arena5v5Card(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArenaHomePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SurvivalToolsCard(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.survivalTools,
                  ),
                ),
                const SizedBox(height: 16),
                _CyberIntelCard(
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
  final String userName;

  const _HeaderSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Centered
      children: [
        Text(
          'PUSAT MISI', // Changed query
          style: AppTextStyles.h1.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w900, // Extra Bold
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Siap berpetualang, $userName?',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: BACKGROUND PATTERN PAINTER
// -----------------------------------------------------------------------------
class _BackgroundPattern extends StatelessWidget {
  final List<dynamic> icons; // Changed to dynamic to support Widgets too
  final Color color;

  const _BackgroundPattern({required this.icons, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(8, (index) {
        // Random-ish positioning based on index
        final random = math.Random(index);
        final size = 24.0 + random.nextInt(24); // Size between 24 and 48
        final top = random.nextDouble() * 100; // Only in top 100px area mainly
        final left = (index * 40.0) % 300; // Distributed horizontally
        final angle = (random.nextDouble() - 0.5) * 0.5; // Mild rotation

        final item = icons[index % icons.length];
        Widget patternWidget;

        if (item is IconData) {
          patternWidget = Icon(
            item,
            size: size,
            color: color.withOpacity(0.12), // Subtle opacity requested
          );
        } else if (item is Widget) {
          // Assume widget is correctly sized/colored already if passed directly
          patternWidget = SizedBox(width: size, height: size, child: item);
        } else {
          patternWidget = const SizedBox();
        }

        return Positioned(
          top: top - 20, // Shift up slightly
          left: left - 20, // Shift left
          child: Transform.rotate(angle: angle, child: patternWidget),
        );
      }),
    );
  }
}

// -----------------------------------------------------------------------------
// GRADIENT 3D CARD WIDGET
// -----------------------------------------------------------------------------
class _Gradient3DCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color> colors;
  final Color borderColor;
  final double height;
  final double borderWidth;
  final List<dynamic>? patternIcons; // NEW: Accept pattern icons/widgets

  const _Gradient3DCard({
    required this.child,
    required this.colors,
    required this.borderColor,
    this.onTap,
    this.height = 170,
    this.borderWidth = 6.0,
    this.patternIcons,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // We don't put color/gradient here to allow ClipRRect to work on children
          // The visual container is below
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: Offset(0, borderWidth), // 3D Bottom Border Effect
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
              ),

              // 2. Background Pattern (if provided)
              if (patternIcons != null)
                Positioned.fill(
                  child: _BackgroundPattern(
                    icons: patternIcons!,
                    color: Colors.white,
                  ),
                ),

              // 3. Content (Foreground)
              Padding(padding: const EdgeInsets.all(16), child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CARD IMPLEMENTATIONS
// -----------------------------------------------------------------------------

class _JamnasExclusiveCard extends StatelessWidget {
  final VoidCallback onTap;

  const _JamnasExclusiveCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Gradient3DCard(
          onTap: onTap,
          height: 180, // Cleaner height
          borderWidth: 8.0, // Extra thick border
          colors: const [
            Color(0xFFFFD700), // Bright Gold
            Color(0xFFFF8F00), // Deep Amber
            Color(0xFF8D6E63), // Rich Bronze
          ],
          borderColor: const Color(0xFF5D4037), // Deep Bronze Shadow
          patternIcons: const [
            Icons.event,
            Icons.flag,
            Icons.celebration,
            Icons.location_on,
            Icons.confirmation_number,
          ],
          child: Stack(
            children: [
              // Specific Background Icons for Jamnas (Large ones)
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.location_city_rounded, // Monas placeholder
                    size: 140,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12), // Space for badge
                  Text(
                    'Road to\nJamnas 2026',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Event Tahunan Nasional',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      shadows: [
                        const Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action Button (Bottom Right)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Buka Event',
                            style: AppTextStyles.button.copyWith(
                              color: const Color(0xFFFF8F00), // Amber text
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFFFF8F00),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // "EVENT TERBATAS" Badge
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F), // Red
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), // Matches card radius
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              'EVENT TERBATAS',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Arena5v5Card extends StatelessWidget {
  final VoidCallback onTap;

  const _Arena5v5Card({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Gradient3DCard(
          height: 140, 
          borderWidth: 6.0, 
          colors: const [
            Color(0xFF1A0505), // Dark Red Black
            Color(0xFF2A0010), // Deep Burgundy
            Color(0xFF120005), // Pitch Dark Red
          ],
          borderColor: const Color(0xFF000000), // Pitch Black Shadow
          patternIcons: const [
            Icons.stadium,
            Icons.electric_bolt,
            Icons.rocket_launch,
            Icons.sports_esports,
            Icons.groups,
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Arena 5v5\nCyber-Scout',
                      style: AppTextStyles.h3.copyWith(
                        color: const Color(0xFFFF0055), // Neon Pink
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        shadows: [
                          const Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kompetisi Multiplayer!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFFFF0055).withOpacity(0.8),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _Bouncing3DIconButton(
                onTap: onTap,
                baseColor: const Color(0xFFFF0055), // Neon Pink
                shadowColor: const Color(0xFF990033), // Dark Pink Shadow
                icon: const Icon(
                  Icons.stadium_rounded,
                  color: Color(0xFF111111),
                  size: 44,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0055), // Neon Pink
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20), 
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Text(
              'NEW EVENT🔥',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF111111), // Black
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _JalurPenegakCard extends StatelessWidget {
  final VoidCallback onTap;

  const _JalurPenegakCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Gradient3DCard(
      onTap: onTap,
      height: 140, // Reduced height since progress is gone
      colors: const [
        Color(0xFF84D148), // Lime Green
        Color(0xFF4B9F38), // Scout Green
        Color(0xFF2E7D32), // Forest Green
      ],
      borderColor: const Color(0xFF1B5E20), // Dark Forest Green
      patternIcons: const [
        Icons.terrain,
        Icons.forest,
        Icons.local_fire_department,
        Icons.hiking,
        Icons.agriculture,
      ],
      child: Row(
        // Changed to Row for Horizontal layout
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kitab Sandi\nNusantara',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    shadows: [
                      const Shadow(
                        blurRadius: 2,
                        color: Colors.black26,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai Petualangan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    shadows: [
                      const Shadow(
                        blurRadius: 2,
                        color: Colors.black26,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // We can keep the main icon as well for focus
          Transform.rotate(
            angle: 0.1,
            child: Image.asset(
              'assets/images/tunas_kelapa.png',
              height: 80,
              color: Colors.white.withOpacity(0.8), // Slightly more visible
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (_, __, ___) => Icon(
                Icons.verified,
                color: Colors.white.withOpacity(0.8),
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurvivalToolsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SurvivalToolsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Gradient3DCard(
      height: 140, // Match Arena 5v5 height
      borderWidth: 6.0,
      colors: const [
        Color(0xFF121212), // Almost Black
        Color(0xFF1A1A2E), // Very Dark Blue
        Color(0xFF0F3460), // Deep Navy
      ],
      borderColor: const Color(0xFF000000), // Pitch Black Shadow
      patternIcons: const [
        Icons.explore,
        Icons.map,
        Icons.flashlight_on,
        Icons.backpack,
        Icons.handyman,
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Survival Tools',
                  style: AppTextStyles.h3.copyWith(
                    color: const Color(0xFF00E5FF), // Neon Cyan
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    shadows: [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peralatan Darurat & Peta',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF00E5FF).withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _Bouncing3DIconButton(
            onTap: onTap,
            baseColor: const Color(0xFF00E5FF),
            shadowColor: const Color(0xFF0097A7),
            icon: const Icon(
              Icons.explore_rounded,
              color: Color(0xFF111111),
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _KoleksiTkkCard extends StatelessWidget {
  final VoidCallback onTap;

  const _KoleksiTkkCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Gradient3DCard(
      onTap: onTap,
      height: 160,
      colors: const [
        Color(0xFFFDD835), // Yellow
        Color(0xFFFB8C00), // Orange
        Color(0xFFE65100), // Red Orange
      ],
      borderColor: const Color(0xFFBF360C), // Dark Red Orange
      patternIcons: [
        Image.asset(
          'assets/icons/training/star.png',
          color: Colors.white.withOpacity(0.12),
          colorBlendMode: BlendMode.srcIn,
        ),
        Icons.military_tech,
        Icons.emoji_events,
        Icons.workspace_premium,
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Colors.white,
            size: 48,
          ), // Large Icon
          const SizedBox(height: 12),
          Text(
            'Koleksi\nTKK',
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.1,
              shadows: [
                const Shadow(
                  blurRadius: 2,
                  color: Colors.black26,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberIntelCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CyberIntelCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Gradient3DCard(
      height: 140, // Match others
      borderWidth: 6.0,
      colors: const [
        Color(0xFF0A0A0A), // Near Black
        Color(0xFF002200), // Very Dark Green
        Color(0xFF001100), // Almost Black Green
      ],
      borderColor: const Color(0xFF000000), // Pitch Black Shadow
      patternIcons: const [
        Icons.security,
        Icons.code,
        Icons.fingerprint,
        Icons.vpn_key,
        Icons.terminal,
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cyber Intel',
                  style: AppTextStyles.h3.copyWith(
                    color: const Color(0xFF00FF41), // Matrix Green
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    shadows: [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keamanan & Sandi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF00FF41).withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _Bouncing3DIconButton(
            onTap: onTap,
            baseColor: const Color(0xFF00FF41),
            shadowColor: const Color(0xFF008F11),
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF111111),
                  size: 44,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFF00FF41),
                    size: 20,
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

class _TopographyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double y = 20; y < size.height; y += 40) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 60) {
        path.quadraticBezierTo(x + 20, y + (x % 120 == 0 ? 8 : -8), x + 60, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bouncing3DIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  final Color baseColor;
  final Color shadowColor;
  final double size;

  const _Bouncing3DIconButton({
    required this.icon,
    required this.onTap,
    required this.baseColor,
    required this.shadowColor,
    this.size = 72,
  });

  @override
  State<_Bouncing3DIconButton> createState() => _Bouncing3DIconButtonState();
}

class _Bouncing3DIconButtonState extends State<_Bouncing3DIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size + 4,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: widget.shadowColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    top: _isPressed ? 4 : 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: widget.baseColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: widget.icon),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
