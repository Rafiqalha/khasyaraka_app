import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

class RiverToolPage extends StatefulWidget {
  const RiverToolPage({super.key});

  @override
  State<RiverToolPage> createState() => _RiverToolPageState();
}

class _RiverToolPageState extends State<RiverToolPage> with SingleTickerProviderStateMixin {
  // --- DUO THEME ---
  static const _riverBlue = Color(0xFF0091FF);
  static const _grassGreen = Color(0xFF58CC02);
  static const _grassShadow = Color(0xFF46A302);
  static const _dangerRed = Color(0xFFFF4B4B);
  static const _dangerShadow = Color(0xFFD93A3A);
  static const _grey = Color(0xFFE5E5E5);

  late TabController _tabController;

  // --- SENSORS DATA ---
  double _heading = 0.0;
  double _pitch = 0.0; // Spirit Level
  double _roll = 0.0; // Spirit Level
  StreamSubscription? _compassSub;
  StreamSubscription? _accelSub;

  // --- WIDTH TOOL STATE ---
  double? _startHeading;
  double? _endHeading;
  final TextEditingController _distanceController = TextEditingController(text: "10");
  double _calculatedWidth = 0.0;

  // --- FLOW TOOL STATE ---
  bool _isStopwatchRunning = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _formattedTime = "00:00.0";
  final TextEditingController _flowDistanceController = TextEditingController(text: "10");
  double _flowSpeed = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initSensors();
  }

  void _initSensors() {
    // Compass
    _compassSub = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading ?? 0.0;
        });
      }
    });

    // Accelerometer for Spirit Level
    _accelSub = accelerometerEventStream().listen((event) {
      if (mounted) {
        setState(() {
          // Simple tilt calculation
          _pitch = event.y; 
          _roll = event.x;
        });
      }
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _accelSub?.cancel();
    _tabController.dispose();
    _timer?.cancel();
    _distanceController.dispose();
    _flowDistanceController.dispose();
    super.dispose();
  }

  // --- LOGIC: WIDTH ---
  void _setStartPoint() {
    setState(() {
      _startHeading = _heading;
      _endHeading = null;
      _calculatedWidth = 0.0;
    });
    _showSnack("TITIK AWAL DIKUNCI!", _grassGreen);
  }

  void _calculateRiverWidth() {
    if (_startHeading == null) return;
    
    double current = _heading;
    double diff = (current - _startHeading!).abs();
    if (diff > 180) diff = 360 - diff; // Handle wrap-around

    double walkDist = double.tryParse(_distanceController.text) ?? 0.0;
    
    if (walkDist <= 0) {
      _showSnack("MASUKKAN JARAK LANGKAH!", _dangerRed);
      return;
    }

    // Width = Distance * tan(theta)
    // Convert degrees to radians
    double thetaRad = diff * (math.pi / 180);
    double width = walkDist * math.tan(thetaRad);

    setState(() {
      _endHeading = current;
      _calculatedWidth = width.abs();
    });
  }

  // --- LOGIC: FLOW ---
  void _toggleStopwatch() {
    if (_isStopwatchRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _calculateFlowSpeed();
    } else {
      _stopwatch.reset();
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), _updateTime);
      _flowSpeed = 0.0;
    }
    setState(() => _isStopwatchRunning = !_isStopwatchRunning);
  }

  void _updateTime(Timer timer) {
    if (mounted) {
      setState(() {
        _formattedTime = "${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}.${(_stopwatch.elapsed.inMilliseconds % 1000 ~/ 100)}";
      });
    }
  }

  void _calculateFlowSpeed() {
    double dist = double.tryParse(_flowDistanceController.text) ?? 10.0;
    double timeSec = _stopwatch.elapsedMilliseconds / 1000.0;
    if (timeSec > 0) {
      setState(() {
        _flowSpeed = dist / timeSec;
      });
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Navigasi Arus 🌊", style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF4B4B4B))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4B4B4B)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _riverBlue,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize: 16),
          indicatorColor: _riverBlue,
          indicatorWeight: 4,
          tabs: const [
            Tab(text: "LEBAR SUNGAI"),
            Tab(text: "LAJU ARUS"),
          ],
        ),
        actions: [
          _buildSpiritLevel(),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWidthTab(),
          _buildFlowTab(),
        ],
      ),
    );
  }

  // --- TAB 1: WIDTH MEASUREMENT ---
  Widget _buildWidthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: "ESTIMASI LEBAR",
            value: "${_calculatedWidth.toStringAsFixed(1)} m",
            color: _riverBlue,
            icon: Icons.straighten,
          ),
          const SizedBox(height: 24),
          
          Text("1. BIDIK & KUNCI SUDUT AWAL", style: _labelStyle()),
          const SizedBox(height: 8),
          _build3DButton(
            text: _startHeading == null ? "SET TITIK AWAL" : "TITIK AWAL: ${_startHeading!.toStringAsFixed(0)}°",
            color: _startHeading == null ? _grassGreen : Colors.grey,
            shadowColor: _startHeading == null ? _grassShadow : Colors.grey.shade700,
            onTap: _setStartPoint,
            icon: Icons.gps_fixed,
          ),
          
          const SizedBox(height: 24),
          Text("2. MASUKKAN JARAK GESER (METER)", style: _labelStyle()),
          const SizedBox(height: 8),
          TextField(
            controller: _distanceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: _inputDecoration("Contoh: 10"),
          ),

          const SizedBox(height: 24),
          Text("3. BIDIK TITIK SEBERANG LAGI", style: _labelStyle()),
          const SizedBox(height: 8),
          _build3DButton(
            text: "HITUNG LEBAR",
            color: _riverBlue,
            shadowColor: const Color(0xFF0070C9),
            onTap: _calculateRiverWidth,
            icon: Icons.calculate,
          ),

          const SizedBox(height: 24),
          if (_endHeading != null)
             Center(child: Text("Sudut Akhir: ${_endHeading!.toStringAsFixed(0)}° (Bedanya: ${(_heading - (_startHeading ?? 0)).abs().toStringAsFixed(1)}°)", style: const TextStyle(fontFamily: 'Fredoka', color: Colors.grey))),
        
          const SizedBox(height: 40),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // --- TAB 2: FLOW MEASUREMENT ---
  Widget _buildFlowTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: "LAJU ARUS",
            value: "${_flowSpeed.toStringAsFixed(2)} m/s",
            color: _riverBlue, // Use Blue for water context, or Orange as per user request? User asked for Orange in "Data Panel". Let's stick to Orange for Speed Result.
            overrideColor: const Color(0xFFFF9600),
            icon: Icons.speed,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _flowSpeed < 0.5 ? "ARUS TENANG" : (_flowSpeed < 1.0 ? "ARUS SEDANG" : "ARUS DERAS!"),
              style: TextStyle(
                fontFamily: 'Fredoka', 
                fontWeight: FontWeight.bold, 
                color: _flowSpeed < 1.0 ? _grassGreen : _dangerRed
              )
            )
          ),

          const SizedBox(height: 32),
          Text("JARAK LINTASAN (METER)", style: _labelStyle()),
          const SizedBox(height: 8),
          TextField(
            controller: _flowDistanceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: _inputDecoration("Contoh: 10"),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              _formattedTime,
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF4B4B4B)),
            ),
          ),
          
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: _buildCircular3DButton(
                text: _isStopwatchRunning ? "STOP" : "START",
                color: _isStopwatchRunning ? _dangerRed : _grassGreen,
                shadowColor: _isStopwatchRunning ? _dangerShadow : _grassShadow,
                onTap: _toggleStopwatch,
              ),
            ),
          ),

          const SizedBox(height: 40),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  // --- WIDGETS ---
  
  Widget _buildSpiritLevel() {
    // Mini visualizer for tilt
    bool isLevel = _pitch.abs() < 1.0 && _roll.abs() < 1.0;
    return Container(
      width: 40, height: 40,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isLevel ? _grassGreen : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required Color color, required IconData icon, Color? overrideColor}) {
    final displayColor = overrideColor ?? color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 5), // 3D Effect
          top: BorderSide(color: Color(0xFFE5E5E5), width: 2),
          left: BorderSide(color: Color(0xFFE5E5E5), width: 2),
          right: BorderSide(color: Color(0xFFE5E5E5), width: 2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: displayColor, size: 32),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontFamily: 'Fredoka', color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value, style: TextStyle(fontFamily: 'Fredoka', color: displayColor, fontWeight: FontWeight.bold, fontSize: 32)),
        ],
      ),
    );
  }

  Widget _build3DButton({required String text, required Color color, required Color shadowColor, required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: shadowColor, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontFamily: 'Fredoka', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircular3DButton({required String text, required Color color, required Color shadowColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: shadowColor, offset: const Offset(0, 10), blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontFamily: 'Fredoka', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'Fredoka', color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _riverBlue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _grey, width: 2),
      ),
    );
  }

  TextStyle _labelStyle() {
    return const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey);
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Hasil adalah ESTIMASI. Jangan terlalu dekat dengan sunga yang deras!",
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
