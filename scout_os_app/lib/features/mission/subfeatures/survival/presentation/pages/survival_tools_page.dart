import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class SurvivalToolsPage extends StatelessWidget {
  const SurvivalToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi data alat secara statis
    final tools = <_SurvivalTool>[
      _SurvivalTool(
        title: 'Compass Pro',
        subtitle: 'MAGNETOMETER',
        icon: Icons.explore,
        backgroundIcons: [Icons.navigation, Icons.map, Icons.wind_power],
        gradientColors: [Colors.cyanAccent, Colors.blue.shade800],
        routeName: AppRoutes.survivalCompass,
        isAvailable: true,
      ),
      _SurvivalTool(
        title: 'Clinometer',
        subtitle: 'ANGLE_MEASURE',
        icon: Icons.signal_cellular_alt,
        backgroundIcons: [
          Icons.terrain,
          Icons.straighten,
          Icons.change_history,
        ],
        gradientColors: [Colors.purpleAccent, Colors.indigo.shade800],
        routeName: AppRoutes.survivalClinometer,
        isAvailable: true,
      ),
      _SurvivalTool(
        title: 'GPS Tracker',
        subtitle: 'COORD_FINDER',
        icon: Icons.gps_fixed,
        backgroundIcons: [Icons.satellite_alt, Icons.pin_drop, Icons.radar],
        gradientColors: [Colors.tealAccent, Colors.green.shade800],
        routeName: AppRoutes.survivalGpsTracker,
        isAvailable: true,
      ),
      _SurvivalTool(
        title: 'Leveler',
        subtitle: 'WATERPASS',
        icon: Icons.water_drop,
        backgroundIcons: [
          Icons.balance,
          Icons.linear_scale,
          Icons.construction,
        ],
        gradientColors: [Colors.orangeAccent, Colors.deepOrange.shade800],
        routeName: AppRoutes
            .survivalRiver, // Using 'River' route as placeholder for Leveler logic if applicable, or check routes
        isAvailable: true,
      ),
      _SurvivalTool(
        title: 'Pedometer',
        subtitle: 'STEP_COUNTER',
        icon: Icons.directions_run,
        backgroundIcons: [
          Icons.do_not_step,
          Icons.timer,
          Icons.health_and_safety,
        ],
        gradientColors: [Colors.pinkAccent, Colors.red.shade800],
        routeName: AppRoutes.survivalPedometer,
        isAvailable: true,
      ),
      _SurvivalTool(
        title: 'Morse Torch',
        subtitle: 'FLASHLIGHT',
        icon: Icons.flashlight_on,
        backgroundIcons: [Icons.lightbulb, Icons.highlight, Icons.more_horiz],
        gradientColors: [Colors.amberAccent, Colors.orange.shade800],
        routeName: AppRoutes.survivalMorse,
        isAvailable: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SURVIVAL KIT',
          style: GoogleFonts.fredoka(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: GridView.builder(
          itemCount: tools.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85, // Taller for 3D effect
          ),
          itemBuilder: (context, index) {
            return _buildSurvivalCard(context, tools[index]);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXCLUSIVE 3D SURVIVAL CARD
  // ---------------------------------------------------------------------------
  Widget _buildSurvivalCard(BuildContext context, _SurvivalTool tool) {
    // Darker shade logic for border
    final Color borderBottomColor = HSLColor.fromColor(tool.gradientColors.last)
        .withLightness(
          (HSLColor.fromColor(tool.gradientColors.last).lightness - 0.2).clamp(
            0.0,
            1.0,
          ),
        )
        .toColor();

    return GestureDetector(
      onTap: () {
        if (tool.isAvailable && tool.routeName != null) {
          Navigator.pushNamed(context, tool.routeName!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${tool.title} coming soon...',
                style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tool.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: tool.gradientColors.last.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: borderBottomColor,
              width: 5.0, // 3D Effect
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // ---------------------------------------------------------------
              // LAYER 1: Rich Icon Decoration (Watermark)
              // ---------------------------------------------------------------
              if (tool.backgroundIcons.isNotEmpty) ...[
                Positioned(
                  right: -20,
                  top: -20,
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Icon(
                      tool.backgroundIcons[0],
                      color: Colors.white.withValues(alpha: 0.15),
                      size: 90,
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -10,
                  child: Transform.rotate(
                    angle: math.pi / 8,
                    child: Icon(
                      tool.backgroundIcons.length > 1
                          ? tool.backgroundIcons[1]
                          : tool.backgroundIcons[0],
                      color: Colors.white.withValues(alpha: 0.12),
                      size: 80,
                    ),
                  ),
                ),
                // Third icon if available
                if (tool.backgroundIcons.length > 2)
                  Positioned(
                    right: 40,
                    bottom: 20,
                    child: Transform.rotate(
                      angle: 0,
                      child: Icon(
                        tool.backgroundIcons[2],
                        color: Colors.white.withValues(alpha: 0.08),
                        size: 40,
                      ),
                    ),
                  ),
              ],

              // ---------------------------------------------------------------
              // LAYER 2: Main Content
              // ---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main Icon
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.2,
                        ), // Glassy circle
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(tool.icon, size: 40, color: Colors.white),
                    ),
                    const Spacer(),

                    // Title
                    Text(
                      tool.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle (Monospace)
                    Text(
                      tool.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8), // Padding fix
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Model data sederhana
class _SurvivalTool {
  const _SurvivalTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundIcons,
    required this.gradientColors,
    this.routeName,
    this.isAvailable = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<IconData> backgroundIcons;
  final List<Color> gradientColors;
  final String? routeName;
  final bool isAvailable;
}
