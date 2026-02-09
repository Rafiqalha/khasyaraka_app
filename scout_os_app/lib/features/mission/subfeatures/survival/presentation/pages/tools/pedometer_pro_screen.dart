import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerProScreen extends StatefulWidget {
  const PedometerProScreen({super.key});

  @override
  State<PedometerProScreen> createState() => _PedometerProScreenState();
}

class _PedometerProScreenState extends State<PedometerProScreen> with SingleTickerProviderStateMixin {
  // Duolingo Colors
  static const Color _duoGreen = Color(0xFF58CC02);
  static const Color _duoGreenShadow = Color(0xFF46A302);
  static const Color _duoBlue = Color(0xFF1CB0F6);
  static const Color _duoBlueShadow = Color(0xFF1899D6);
  static const Color _duoOrange = Color(0xFFFF9600);
  static const Color _duoOrangeShadow = Color(0xFFE58700);
  static const Color _duoRed = Color(0xFFFF4B4B);
  static const Color _duoRedShadow = Color(0xFFD93A3A);
  
  // State Variables
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  
  String _status = 'Menunggu Sensor...';
  String _stepError = '';
  
  int _steps = 0;
  int _sessionStartSteps = 0; // The step count when "Reset" was pressed
  int _lastStreamSteps = 0; // The raw value from the stream
  
  // Adaptive Algorithm
  double _baseStepLength = 0.7; // Meters
  double _currentPitch = 0.0;
  double _slopeFactor = 1.0;
  double _totalDistance = 0.0;
  
  // Calibration
  bool _isCalibrating = false;
  Position? _startPosition;
  int _calibrationStartSteps = 0;
  
  @override
  void initState() {
    super.initState();
    _initPermissions();
    _initSensors();
  }
  
  Future<void> _initPermissions() async {
    // Request multiple permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.activityRecognition,
      Permission.location,
    ].request();

    if (statuses[Permission.activityRecognition]!.isGranted) {
      _initPedometer();
    } else {
      if (mounted) {
        setState(() {
          _status = 'Izin Ditolak';
          _stepError = 'Izin Aktivitas Fisik diperlukan untuk menghitung langkah.';
        });
      }
    }
  }

  void _initPedometer() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen(
      (status) {
         if (mounted) setState(() => _status = status.status);
      },
      onError: (error) {
         if (mounted) setState(() {
           _status = 'Sensor Error';
           _stepError = 'Status Sensor Error: $error';
         });
      },
    );

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
        _onStepCount,
        onError: (error) {
           if (mounted) setState(() {
             _status = 'Step Sensor Error';
             _stepError = 'Penghitung Langkah Error: $error\nPastikan perangkat mendukung sensor langkah.';
           });
        },
    );
  }

  void _initSensors() {
    _accelSubscription = accelerometerEventStream().listen((event) {
      if (mounted) {
        // Calculate pitch (simplified)
        double normOfG = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        double pitch = asin(event.y / normOfG) * (180 / pi);
        
        setState(() {
          _currentPitch = pitch;
          _updateSlopeFactor(pitch);
        });
      }
    });
  }
  
  void _updateSlopeFactor(double pitch) {
    if (pitch.abs() > 15) {
      if (pitch > 0) {
        _slopeFactor = 1.2; // Harder/Uphill assumption for now
      } else {
        _slopeFactor = 0.9; // Easier/Downhill
      }
    } else {
      _slopeFactor = 1.0;
    }
  }

  void _onStepCount(StepCount event) {
    if (mounted) {
      setState(() {
        // If this is the first data point, sync session start
        if (_sessionStartSteps == 0 && _steps == 0) {
          _sessionStartSteps = event.steps;
        }
        
        _lastStreamSteps = event.steps;
        int currentSessionSteps = _lastStreamSteps - _sessionStartSteps;
        
        // Calculate delta for distance since last update
        int delta = currentSessionSteps - _steps;
        if (delta > 0) {
          _totalDistance += (delta * _baseStepLength * _slopeFactor);
          // Haptic every 100 steps
          if (_steps % 100 == 0) HapticFeedback.lightImpact();
        }
        
        _steps = currentSessionSteps;
        _stepError = ''; // Clear error if we get data
      });
      
      // Calibration Logic
      if (_isCalibrating) {
        _checkCalibration();
      }
    }
  }
  
  void _resetSession() {
    setState(() {
      _sessionStartSteps = _lastStreamSteps;
      _steps = 0;
      _totalDistance = 0.0;
    });
    HapticFeedback.mediumImpact();
  }
  
  Future<void> _startCalibration() async {
    Position start = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _isCalibrating = true;
      _startPosition = start;
      _calibrationStartSteps = _steps; // Use session steps
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kalibrasi dimulai! Jalan lurus 100m."), backgroundColor: _duoBlue),
      );
    }
  }
  
  Future<void> _checkCalibration() async {
    if (_startPosition == null) return;
    
    Position current = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    double dist = Geolocator.distanceBetween(
      _startPosition!.latitude, _startPosition!.longitude,
      current.latitude, current.longitude
    );
    
    if (dist >= 100) {
      // Finished 100m
      int stepsTaken = _steps - _calibrationStartSteps;
      if (stepsTaken > 0) {
         double newStride = 100.0 / stepsTaken;
         setState(() {
           _baseStepLength = newStride;
           _isCalibrating = false;
           _startPosition = null;
         });
         
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Kalibrasi Selesai! Langkah barumu: ${newStride.toStringAsFixed(2)}m"), backgroundColor: _duoOrange),
           );
         }
      }
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: _duoBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _duoBlueShadow, offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        title: Text(
          "Alat Ukur Langkah",
          style: GoogleFonts.fredoka(color: Colors.grey.shade700, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _resetSession,
            icon: const Icon(Icons.refresh_rounded, color: _duoRed, size: 28),
            tooltip: 'Reset Session',
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Error Display
              if (_stepError.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _duoRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _duoRed),
                  ),
                  child: Row(
                    children: [
                       const Icon(Icons.error_outline, color: _duoRed),
                       const SizedBox(width: 12),
                       Expanded(child: Text(_stepError, style: GoogleFonts.fredoka(color: _duoRed))),
                    ],
                  ),
                ),

              // 1. Big Session Counter (Replaces Progress Circle)
              _buildSessionCounter(),
              
              const SizedBox(height: 30),
              
              // 2. Data Cards
              Row(
                children: [
                   Expanded(child: _build3DCard("Medan (Pitch)", "${_currentPitch.abs().toStringAsFixed(0)}°", Icons.landscape, _duoOrange, _duoOrangeShadow)),
                   const SizedBox(width: 12),
                   Expanded(child: _build3DCard("Stride Length", "${_baseStepLength.toStringAsFixed(2)} m", Icons.straighten, _duoBlue, _duoBlueShadow)),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // 3. Calibration Button
              _buildCalibrationButton(),
              
              const SizedBox(height: 20),
              
              // Status
               Text(
                "Status Sensor: $_status",
                style: GoogleFonts.fredoka(color: Colors.grey.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSessionCounter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: _duoGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: _duoGreenShadow, offset: Offset(0, 8), blurRadius: 0)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "$_steps",
                style: GoogleFonts.fredoka(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
              ),
              const SizedBox(width: 8),
              Text(
                "Langkah",
                style: GoogleFonts.fredoka(fontSize: 24, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_walk, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  "= ${_totalDistance.toStringAsFixed(1)} Meter",
                  style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _build3DCard(String title, String value, IconData icon, Color color, Color shadow, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 4),
            blurRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            title,
            style: GoogleFonts.fredoka(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalibrationButton() {
    return GestureDetector(
      onTap: _isCalibrating ? null : _startCalibration,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isCalibrating ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isCalibrating ? Colors.grey : _duoBlue, width: 2),
          boxShadow: _isCalibrating ? [] : [
             const BoxShadow(color: _duoBlueShadow, offset: Offset(0, 4), blurRadius: 0)
          ],
        ),
        child: Center(
          child: Text(
            _isCalibrating ? "Sedang Kalibrasi (Jalan 100m)..." : "KALIBRASI LANGKAH (100M)",
            style: GoogleFonts.fredoka(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: _isCalibrating ? Colors.white : _duoBlue
            ),
          ),
        ),
      ),
    );
  }
}
