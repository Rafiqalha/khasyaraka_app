import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_tools_controller.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/presentation/widgets/survival_card.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class SurvivalDashboardPage extends StatefulWidget {
  const SurvivalDashboardPage({super.key});

  @override
  State<SurvivalDashboardPage> createState() => _SurvivalDashboardPageState();
}

class _SurvivalDashboardPageState extends State<SurvivalDashboardPage> {
  // Tactical/Dark theme colors
  static const _darkBackground = Color(0xFF0D1B2A);
  static const _darkCard = Color(0xFF1B2F47);
  static const _tacticalGreen = Color(0xFF00D084);
  static const _accentOrange = Color(0xFFFF6B35);
  static const _textLight = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize all sensors when page loads
      context.read<SurvivalToolsController>().initializeSensors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // Compass Tool Card
            SurvivalCard(
              title: '🧭 Kompas',
              subtitle: 'Magnetometer',
              description: 'Real-time magnetic heading',
              accentColor: _tacticalGreen,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.survivalCompass),
              preview: _CompassPreview(),
            ),
            // Clinometer Tool Card
            SurvivalCard(
              title: '📐 Klinometer',
              subtitle: 'Angle Meter',
              description: 'Pitch & roll angles',
              accentColor: _accentOrange,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.survivalClinometer),
              preview: _ClinoPreview(),
            ),
            // GPS Tracker Tool Card
            SurvivalCard(
              title: '📍 GPS Tracker',
              subtitle: 'Location Data',
              description: 'Coordinates & altitude',
              accentColor: _tacticalGreen,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.survivalGpsTracker),
              preview: _GpsPreview(),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _darkCard,
      elevation: 8,
      shadowColor: _tacticalGreen.withAlpha(100),
      title: Text(
        'SURVIVAL KIT',
        style: GoogleFonts.cinzel(
          color: _tacticalGreen,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 2,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(height: 2, color: _tacticalGreen),
      ),
    );
  }
}

/// Live compass preview widget
class _CompassPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SurvivalToolsController>(
      builder: (context, controller, _) {
        final data = controller.compassData;
        final error = controller.compassError;

        if (error != null) {
          return Text(
            '⚠️ Compass Error',
            style: GoogleFonts.robotoMono(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          );
        }

        if (data == null) {
          return SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.grey.shade600,
              strokeWidth: 2,
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${data.heading.toStringAsFixed(0)}°',
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              controller.getCompassDirection(data.heading),
              style: GoogleFonts.robotoMono(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Live clinometer preview widget
class _ClinoPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SurvivalToolsController>(
      builder: (context, controller, _) {
        final data = controller.clinoData;
        final error = controller.clinoError;

        if (error != null) {
          return Text(
            '⚠️ Accel Error',
            style: GoogleFonts.robotoMono(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          );
        }

        if (data == null) {
          return SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.grey.shade600,
              strokeWidth: 2,
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${data.pitchAngle.toStringAsFixed(1)}°',
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Pitch',
              style: GoogleFonts.robotoMono(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Live GPS preview widget
class _GpsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SurvivalToolsController>(
      builder: (context, controller, _) {
        final data = controller.gpsData;
        final error = controller.gpsError;

        if (error != null) {
          return Text(
            '⚠️ GPS Error',
            style: GoogleFonts.robotoMono(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          );
        }

        if (data == null) {
          return SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.grey.shade600,
              strokeWidth: 2,
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${data.latitude.toStringAsFixed(4)}',
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${data.longitude.toStringAsFixed(4)}',
              style: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${data.altitude.toStringAsFixed(1)}m',
              style: GoogleFonts.robotoMono(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
