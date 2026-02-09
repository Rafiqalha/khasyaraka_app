import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Represents real-time compass data
class CompassData {
  final double heading; // 0-360 degrees
  final double magneticField;
  final int accuracy;

  CompassData({
    required this.heading,
    required this.magneticField,
    required this.accuracy,
  });
}

/// Represents real-time clinometer (accelerometer) data
class ClinoData {
  final double pitchAngle; // X-axis angle
  final double rollAngle; // Y-axis angle
  final double yawAngle; // Z-axis angle

  ClinoData({
    required this.pitchAngle,
    required this.rollAngle,
    required this.yawAngle,
  });
}

/// Represents real-time GPS data
class GpsData {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double speed;

  GpsData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
  });
}

/// Survival Tools Controller - Handles ALL local sensor data
/// NO BACKEND CALLS. 100% OFFLINE.
class SurvivalToolsController extends ChangeNotifier {
  // Compass streams
  late Stream<MagnetometerEvent> _compassStream;
  CompassData? _compassData;
  String? _compassError;

  // Clinometer (Accelerometer) streams
  late Stream<UserAccelerometerEvent> _accelStream;
  ClinoData? _clinoData;
  String? _clinoError;

  // GPS streams
  late Stream<Position> _gpsStream;
  GpsData? _gpsData;
  String? _gpsError;
  bool _gpsEnabled = false;

  // Getters
  CompassData? get compassData => _compassData;
  String? get compassError => _compassError;

  ClinoData? get clinoData => _clinoData;
  String? get clinoError => _clinoError;

  GpsData? get gpsData => _gpsData;
  String? get gpsError => _gpsError;
  bool get gpsEnabled => _gpsEnabled;

  /// Initialize all sensor streams
  Future<void> initializeSensors() async {
    _initializeCompass();
    _initializeClinometer();
    await _initializeGps();
  }

  /// Initialize Compass (Magnetometer)
  void _initializeCompass() {
    try {
      _compassStream = magnetometerEventStream();
      _compassStream.listen(
        (MagnetometerEvent event) {
          final heading = (math.atan2(event.y, event.x) * 180 / math.pi + 360) % 360;
          final magneticField = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          
          _compassData = CompassData(
            heading: heading,
            magneticField: magneticField,
            accuracy: 2,
          );
          _compassError = null;
          notifyListeners();
        },
        onError: (error) {
          _compassError = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _compassError = 'Failed to initialize compass: $e';
      notifyListeners();
    }
  }

  /// Initialize Clinometer (Accelerometer)
  void _initializeClinometer() {
    try {
      _accelStream = userAccelerometerEventStream();
      _accelStream.listen(
        (UserAccelerometerEvent event) {
          // Convert accelerometer values to angles
          final pitchAngle = _calculateAngle(event.y, event.z);
          final rollAngle = _calculateAngle(event.x, event.z);
          final yawAngle =
              _atan2Angle(event.x, event.y); // Yaw from X,Y plane

          _clinoData = ClinoData(
            pitchAngle: pitchAngle,
            rollAngle: rollAngle,
            yawAngle: yawAngle,
          );
          _clinoError = null;
          notifyListeners();
        },
        onError: (error) {
          _clinoError = 'Failed to initialize clinometer: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _clinoError = 'Failed to initialize clinometer: $e';
      notifyListeners();
    }
  }

  /// Initialize GPS (Geolocator)
  Future<void> _initializeGps() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _gpsError =
            'GPS permission denied. Enable location in device settings.';
        notifyListeners();
        return;
      }

      _gpsEnabled = true;

      // Get initial position
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateGpsData(initialPosition);

      // Listen to position stream with distance filter
      _gpsStream = Geolocator.getPositionStream();

      _gpsStream.listen(
        (Position position) {
          _updateGpsData(position);
        },
        onError: (error) {
          _gpsError = 'GPS Error: $error';
          _gpsEnabled = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _gpsError = 'Failed to initialize GPS: $e';
      _gpsEnabled = false;
      notifyListeners();
    }
  }

  /// Update GPS data and notify listeners
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
  /// Used for pitch and roll calculation
  double _calculateAngle(double a, double b) {
    return (math.atan2(a, b) * 180 / math.pi).toDouble();
  }

  /// Calculate yaw angle using atan2
  double _atan2Angle(double x, double y) {
    return (math.atan2(y, x) * 180 / math.pi).toDouble();
  }

  /// Get compass heading as cardinal direction (N, NE, E, etc.)
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

  /// Get altitude interpretation
  String getAltitudeInfo(double altitude) {
    if (altitude < 0) return 'Below sea level';
    if (altitude < 100) return 'Low altitude';
    if (altitude < 500) return 'Moderate altitude';
    if (altitude < 1500) return 'High altitude';
    return 'Very high altitude';
  }

  /// Get accuracy interpretation
  String getAccuracyLevel(double accuracy) {
    if (accuracy < 5) return 'Excellent';
    if (accuracy < 10) return 'Good';
    if (accuracy < 20) return 'Moderate';
    if (accuracy < 50) return 'Poor';
    return 'Very Poor';
  }

  @override
  void dispose() {
    try {
      // Stream subscriptions are auto-managed by the listeners
      // No explicit cancel needed
    } catch (e) {
      // Ignore errors during cleanup
    }
    super.dispose();
  }
}
