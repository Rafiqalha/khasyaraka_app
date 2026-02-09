# 📋 Survival Module Refactoring - Complete Code Reference

This document provides all the code snippets you'll need to implement the refactoring.

---

## Backend: FastAPI Router

### File: `scout_os_backend/app/modules/survival/router.py`

```python
"""
Survival Module Router - Simplified Offline Configuration

This module provides minimal configuration endpoints for Survival Tools.
All tools operate 100% offline using device sensors.
No gamification, no XP tracking, no progression.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.core.security import get_current_user

router = APIRouter()


class SurvivalToolConfig:
    """Static configuration for available survival tools"""
    TOOLS = {
        "compass": {
            "name": "🧭 Kompas",
            "description": "Kompas magnetik real-time. Gunakan di lapangan untuk navigasi.",
            "icon": "explore",
            "available": True,
            "offline": True,
        },
        "clinometer": {
            "name": "📐 Klinometer",
            "description": "Alat ukur sudut dan tinggi. Gunakan untuk mengukur ketinggian pohon atau bangunan.",
            "icon": "straighten",
            "available": True,
            "offline": True,
        },
        "gps": {
            "name": "📍 GPS Tracker",
            "description": "Pelacak GPS offline. Menampilkan lintang, bujur, ketinggian, dan akurasi.",
            "icon": "gps_fixed",
            "available": True,
            "offline": True,
        },
    }


@router.get("/tools/config")
async def get_tools_config(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get configuration for all available survival tools.
    
    This endpoint returns static tool configurations.
    Used by frontend to initialize the tool dashboard.
    
    No database queries needed. Backend is optional for Survival module.
    
    Returns:
        dict: Tool configurations and availability status
    """
    return {
        "success": True,
        "tools": SurvivalToolConfig.TOOLS,
        "offline_mode": True,
        "message": "All survival tools are 100% offline. Internet not required!",
        "user_id": int(current_user.get("sub")),
    }


@router.get("/health")
async def health_check():
    """
    Health check endpoint for Survival module.
    
    Backend is optional for Survival - this endpoint is mainly for monitoring.
    All tools work offline even if backend is down.
    
    Returns:
        dict: Health status
    """
    return {
        "status": "ok",
        "module": "survival",
        "offline_capable": True,
        "backend_required": False,
        "tools": list(SurvivalToolConfig.TOOLS.keys()),
    }


# === DEPRECATED ENDPOINTS (DO NOT USE) ===

# The following endpoints are deprecated and removed
# Old XP/Level tracking is no longer used

# ❌ @router.get("/mastery") - REMOVED
# ❌ @router.post("/action") - REMOVED
# ❌ Database tables: survival_mastery - NO LONGER USED
```

---

## Frontend: Complete Controller

### File: `lib/features/mission/subfeatures/survival/logic/survival_tools_controller.dart`

```dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Real-time compass/magnetometer data
class CompassData {
  final double heading;              // 0-360 degrees
  final double magneticField;        // μT (microtesla)
  final int accuracy;                // degrees

  CompassData({
    required this.heading,
    required this.magneticField,
    required this.accuracy,
  });
}

/// Real-time clinometer/accelerometer data
class ClinoData {
  final double pitchAngle;           // X-axis angle (forward/back)
  final double rollAngle;            // Y-axis angle (left/right)
  final double yawAngle;             // Z-axis angle (rotation)

  ClinoData({
    required this.pitchAngle,
    required this.rollAngle,
    required this.yawAngle,
  });
}

/// Real-time GPS/location data
class GpsData {
  final double latitude;
  final double longitude;
  final double altitude;             // meters
  final double accuracy;             // meters
  final double speed;                // m/s

  GpsData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
  });
}

/// Main controller for ALL Survival Tools
/// Handles local sensor streams only - NO API CALLS
/// 100% OFFLINE OPERATION
class SurvivalToolsController extends ChangeNotifier {
  // ===== COMPASS STREAM =====
  late StreamSubscription<CompassEvent> _compassSubscription;
  CompassData? _compassData;
  String? _compassError;

  // ===== CLINOMETER STREAM =====
  late StreamSubscription<AccelerometerEvent> _accelSubscription;
  ClinoData? _clinoData;
  String? _clinoError;

  // ===== GPS STREAM =====
  late StreamSubscription<Position> _gpsSubscription;
  GpsData? _gpsData;
  String? _gpsError;
  bool _gpsEnabled = false;

  // ===== GETTERS =====

  CompassData? get compassData => _compassData;
  String? get compassError => _compassError;

  ClinoData? get clinoData => _clinoData;
  String? get clinoError => _clinoError;

  GpsData? get gpsData => _gpsData;
  String? get gpsError => _gpsError;
  bool get gpsEnabled => _gpsEnabled;

  /// Initialize ALL sensor streams
  /// Call this once when app loads or page opens
  Future<void> initializeSensors() async {
    _initializeCompass();
    _initializeClinometer();
    await _initializeGps();
  }

  /// Setup Compass/Magnetometer Stream
  void _initializeCompass() {
    try {
      _compassSubscription = compassEvents.listen(
        (CompassEvent event) {
          _compassData = CompassData(
            heading: event.heading,
            magneticField: event.magneticField,
            accuracy: event.accuracy,
          );
          _compassError = null;
          notifyListeners();
        },
        onError: (error) {
          _compassError = 'Compass unavailable: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _compassError = 'Failed to initialize compass: $e';
      notifyListeners();
    }
  }

  /// Setup Clinometer/Accelerometer Stream
  void _initializeClinometer() {
    try {
      _accelSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          // Convert accelerometer readings to angles
          final pitchAngle = _calculateAngle(event.y, event.z);
          final rollAngle = _calculateAngle(event.x, event.z);
          final yawAngle = _atan2Angle(event.x, event.y);

          _clinoData = ClinoData(
            pitchAngle: pitchAngle,
            rollAngle: rollAngle,
            yawAngle: yawAngle,
          );
          _clinoError = null;
          notifyListeners();
        },
        onError: (error) {
          _clinoError = 'Accelerometer unavailable: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _clinoError = 'Failed to initialize clinometer: $e';
      notifyListeners();
    }
  }

  /// Setup GPS/Location Stream
  Future<void> _initializeGps() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsError = 'Location services disabled. Enable in device settings.';
        _gpsEnabled = false;
        notifyListeners();
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _gpsError = 'Location permission denied by user.';
        _gpsEnabled = false;
        notifyListeners();
        return;
      }

      _gpsEnabled = true;

      // Get initial position
      try {
        final initialPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        );
        _updateGpsData(initialPosition);
      } catch (e) {
        _gpsError = 'Failed to get initial GPS position: $e';
        _gpsEnabled = false;
        notifyListeners();
        return;
      }

      // Listen to continuous position updates
      _gpsSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters
        ),
      ).listen(
        (Position position) {
          _updateGpsData(position);
        },
        onError: (error) {
          _gpsError = 'GPS Error: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _gpsError = 'Failed to initialize GPS: $e';
      _gpsEnabled = false;
      notifyListeners();
    }
  }

  /// Update GPS data when new position arrives
  void _updateGpsData(Position position) {
    _gpsData = GpsData(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
    );
    _gpsError = null;
    notifyListeners();
  }

  /// Calculate angle from two accelerometer axes
  /// Formula: atan2(a, b) * 180 / π
  double _calculateAngle(double a, double b) {
    return math.atan2(a, b) * 180 / math.pi;
  }

  /// Calculate yaw angle using atan2
  double _atan2Angle(double x, double y) {
    return math.atan2(y, x) * 180 / math.pi;
  }

  /// Convert heading (0-360°) to cardinal direction
  /// Returns: N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
  String getCompassDirection(double heading) {
    final directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW'
    ];
    final index = ((heading + 11.25) / 22.5).toInt() % 16;
    return directions[index];
  }

  /// Get human-readable altitude interpretation
  String getAltitudeInfo(double altitude) {
    if (altitude < 0) return 'Below sea level';
    if (altitude < 100) return 'Low altitude';
    if (altitude < 500) return 'Moderate altitude';
    if (altitude < 1500) return 'High altitude';
    return 'Very high altitude';
  }

  /// Get accuracy level based on GPS error radius
  String getAccuracyLevel(double accuracy) {
    if (accuracy < 5) return 'Excellent';
    if (accuracy < 10) return 'Good';
    if (accuracy < 20) return 'Moderate';
    if (accuracy < 50) return 'Poor';
    return 'Very Poor';
  }

  /// Cleanup streams on dispose
  @override
  void dispose() {
    _compassSubscription.cancel();
    _accelSubscription.cancel();
    _gpsSubscription.cancel();
    super.dispose();
  }
}
```

---

## Frontend: Complete Dashboard Page

### File: `lib/features/mission/subfeatures/survival/presentation/pages/survival_dashboard_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_tools_controller.dart';
import 'package:scout_os_app/routes/app_routes.dart';

class SurvivalDashboardPage extends StatefulWidget {
  const SurvivalDashboardPage({super.key});

  @override
  State<SurvivalDashboardPage> createState() => _SurvivalDashboardPageState();
}

class _SurvivalDashboardPageState extends State<SurvivalDashboardPage> {
  // Tactical Dark Theme Colors
  static const _darkBackground = Color(0xFF0D1B2A);   // Very dark blue
  static const _darkCard = Color(0xFF1B2F47);        // Dark blue-gray
  static const _tacticalGreen = Color(0xFF00D084);   // Bright green
  static const _accentOrange = Color(0xFFFF6B35);    // Tactical orange
  static const _textLight = Color(0xFFE0E0E0);       // Light gray text

  @override
  void initState() {
    super.initState();
    // Initialize sensor streams when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            _buildToolCard(
              context,
              title: '🧭 Kompas',
              subtitle: 'Magnetometer',
              description: 'Real-time magnetic heading',
              color: _tacticalGreen,
              onTap: () => Navigator.pushNamed(context, AppRoutes.survivalCompass),
              child: _CompassPreview(),
            ),
            // Clinometer Tool Card
            _buildToolCard(
              context,
              title: '📐 Klinometer',
              subtitle: 'Angle Meter',
              description: 'Pitch & roll angles',
              color: _accentOrange,
              onTap: () => Navigator.pushNamed(context, AppRoutes.survivalClinometer),
              child: _ClinoPreview(),
            ),
            // GPS Tool Card
            _buildToolCard(
              context,
              title: '📍 GPS Tracker',
              subtitle: 'Location Data',
              description: 'Coordinates & altitude',
              color: _tacticalGreen,
              onTap: () => Navigator.pushNamed(context, AppRoutes.survivalGpsTracker),
              child: _GpsPreview(),
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
        child: Container(
          height: 2,
          color: _tacticalGreen,
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withAlpha(20),
                    color.withAlpha(5),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.robotoMono(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.robotoMono(
                      color: _textLight.withAlpha(180),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Live sensor preview
                  Expanded(
                    child: Center(child: child),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    description,
                    style: GoogleFonts.robotoMono(
                      color: _textLight.withAlpha(150),
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Tap to open hint
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TAP TO OPEN',
                      style: GoogleFonts.robotoMono(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            '⚠️ No Compass',
            style: GoogleFonts.robotoMono(
              color: Colors.red,
              fontSize: 12,
            ),
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
            '⚠️ No Accel',
            style: GoogleFonts.robotoMono(
              color: Colors.red,
              fontSize: 12,
            ),
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
            '⚠️ No GPS',
            style: GoogleFonts.robotoMono(
              color: Colors.red,
              fontSize: 12,
            ),
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
```

---

## Route Configuration

### File: `lib/routes/app_routes.dart` (Additions)

```dart
class AppRoutes {
  // Existing routes...
  
  // ===== SURVIVAL ROUTES =====
  static const survivalDashboard = '/survival/dashboard';
  static const survivalCompass = '/survival/compass';
  static const survivalClinometer = '/survival/clinometer';
  static const survivalGpsTracker = '/survival/gps';
}
```

### Navigation Setup

```dart
// In your Router configuration
GoRoute(
  path: '/survival/dashboard',
  builder: (context, state) => const SurvivalDashboardPage(),
),
GoRoute(
  path: '/survival/compass',
  builder: (context, state) => const CompassToolPage(),
),
GoRoute(
  path: '/survival/clinometer',
  builder: (context, state) => const ClinometerToolPage(),
),
GoRoute(
  path: '/survival/gps',
  builder: (context, state) => const GpsTrackerToolPage(),
),
```

---

## Dependencies Configuration

### File: `pubspec.yaml` (Additions)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies...
  
  # Survival Tools - Sensor Access
  sensors_plus: ^1.4.0          # Magnetometer, Accelerometer
  geolocator: ^9.0.0            # GPS/Location services
  
  # Optional: Compass wrapper (if you prefer higher-level API)
  flutter_compass: ^0.7.0       # Magnetometer wrapper
```

---

## Android Manifest

### File: `android/app/src/main/AndroidManifest.xml` (Add permissions)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application>
    <!-- Your app configuration -->
  </application>

  <!-- Survival Tools Permissions -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.BODY_SENSORS" />

  <!-- Background location (optional, for advanced use) -->
  <!-- <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" /> -->
</manifest>
```

---

## iOS Info.plist

### File: `ios/Runner/Info.plist` (Add keys)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Existing keys... -->

  <!-- Survival Tools Keys -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>The Survival Tools need access to your location to provide GPS tracking and coordinate data.</string>

  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>The Survival Tools need access to your location to provide GPS tracking.</string>

  <key>UIRequiredDeviceCapabilities</key>
  <array>
    <string>gps</string>
    <string>magnetometer</string>
    <string>accelerometer</string>
  </array>

</dict>
</plist>
```

---

## Provider Setup

### File: `lib/main.dart` (or `lib/app.dart`)

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Existing providers...
        
        // Survival Tools Controller
        ChangeNotifierProvider(
          create: (_) => SurvivalToolsController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

**Complete Code Reference**  
**Date:** February 5, 2026  
**Status:** Ready for Implementation
