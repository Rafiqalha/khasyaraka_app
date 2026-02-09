import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ClinometerToolPage extends StatefulWidget {
  const ClinometerToolPage({super.key});

  @override
  State<ClinometerToolPage> createState() => _ClinometerToolPageState();
}

class _ClinometerToolPageState extends State<ClinometerToolPage> {
  // Theme (Exclusive Dark Purple)
  static const Color _bgTop = Color(0xFF2E004B);   
  static const Color _bgBottom = Color(0xFF0D001A); 
  static const Color _accentCyan = Color(0xFF00E5FF);
  static const Color _accentYellow = Color(0xFFFFD600);
  static const Color _glassWhite = Colors.white;

  // Logic State
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _currentAngle = 0.0;
  bool _isLocked = false;
  double? _lockedAngle;
  
  // Inputs
  final TextEditingController _distanceCtrl = TextEditingController();
  final TextEditingController _eyeHeightCtrl = TextEditingController();

  // Result
  double _calculatedHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _accelSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (_isLocked) return;

      // Calculate angle (Pitch)
      double angle = math.atan2(event.y, event.z) * (180 / math.pi);
      
      if (mounted) {
        setState(() {
          _currentAngle = angle;
          // Real-time update if not locked
          _calculateHeight(); 
        });
      }
    });
  }

  void _calculateHeight() {
    double dist = double.tryParse(_distanceCtrl.text.replaceAll(',', '.')) ?? 0;
    double eye = double.tryParse(_eyeHeightCtrl.text.replaceAll(',', '.')) ?? 0;
    
    // Formula: (tan(angle) * distance) + eye_height_meters
    // Use absolute angle for calculation to avoid negative heights
    double angleRad = _currentAngle.abs() * (math.pi / 180);
    double height = (math.tan(angleRad) * dist) + (eye / 100);
    
    _calculatedHeight = height;
  }

  void _toggleLock() {
    // Validation: Distance required to lock
    double dist = double.tryParse(_distanceCtrl.text.replaceAll(',', '.')) ?? 0;
    if (!_isLocked && dist <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masukkan Jarak ke Objek terlebih dahulu!", style: GoogleFonts.fredoka()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    FocusScope.of(context).unfocus(); // Close keyboard

    setState(() {
      if (!_isLocked) {
        // ACTION: LOCK
        _isLocked = true;
        _lockedAngle = _currentAngle;
        _accelSubscription?.pause(); // PAUSE SENSOR
        _calculateHeight(); // Ensure final calculation is captured
      } else {
        // ACTION: UNLOCK / RESET
        _isLocked = false;
        _lockedAngle = null;
        _calculatedHeight = 0.0; // Reset result
        _accelSubscription?.resume(); // RESUME SENSOR
      }
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _distanceCtrl.dispose();
    _eyeHeightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use locked angle if locked, otherwise live angle
    final double displayAngle = _lockedAngle ?? _currentAngle;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "KALKULATOR TINGGI",
          style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 1.2),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // -------------------------------------------------------------
              // A. HEADER & VISUAL SUDUT (THE HERO)
              // -------------------------------------------------------------
              Expanded(
                flex: 4,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Protractor BG
                      CustomPaint(
                        size: const Size(320, 160),
                        painter: _ProtractorPainter(),
                      ),
                      // Needle
                      Transform.rotate(
                        angle: -displayAngle * (math.pi / 180),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 4, height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [_accentCyan.withOpacity(0), _accentCyan], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(color: _accentCyan.withOpacity(0.5), blurRadius: 10)],
                          ),
                        ),
                      ),
                      // Pivot
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 10)]),
                      ),
                      // Real-time Angle Text (Floating)
                      Positioned(
                        bottom: 40,
                        child: Column(
                          children: [
                            Text(
                              "${displayAngle.toStringAsFixed(1)}°",
                              style: GoogleFonts.fredoka(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, height: 1.0),
                            ),
                            Text(
                              "SUDUT PELUNCUR", // Pitch
                              style: GoogleFonts.fredoka(color: Colors.white54, fontSize: 10, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------------------------------------------------
              // B. DASHBOARD HASIL (MAIN RESULT)
              // -------------------------------------------------------------
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _glassWhite.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "PERKIRAAN TINGGI OBJEK",
                        style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 12, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      // Result Display
                      Text(
                        "${_calculatedHeight.toStringAsFixed(2)} METER",
                        style: GoogleFonts.fredoka(
                          color: _isLocked ? _accentYellow : Colors.white30, 
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          shadows: _isLocked ? [BoxShadow(color: _accentYellow.withOpacity(0.3), blurRadius: 20)] : [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------------------------------------------------
              // C. EXCLUSIVE INPUT SECTION (Flat High Contrast UI)
              // -------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildHighContrastInput(
                        controller: _distanceCtrl,
                        label: "Jarak (m)",
                        icon: Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildHighContrastInput(
                        controller: _eyeHeightCtrl,
                        label: "Tinggi Mata (cm)",
                        icon: Icons.accessibility_new,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // D. TOMBOL AKSI (LOCK TOGGLE)
              // -------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                margin: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  onTap: _toggleLock,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isLocked ? Colors.orange[800] : const Color(0xFF00C853), // Orange (Reset) vs Green (Lock)
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        bottom: BorderSide(
                          color: _isLocked ? Colors.orange[900]! : const Color(0xFF007E33), 
                          width: 6,
                        ),
                      ), 
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLocked ? Icons.refresh : Icons.lock,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLocked ? "ULANGI PENGUKURAN" : "KUNCI HASIL UKUR",
                          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighContrastInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
             if (!_isLocked) {
                _calculateHeight();
             }
          },
          style: GoogleFonts.fredoka(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700), // Black on White
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white, // Pure White Background
            prefixIcon: Icon(icon, color: Colors.grey[800], size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Clean look
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            hintText: "0",
            hintStyle: GoogleFonts.fredoka(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// PROTRACTOR PAINTER (Clean & Sharp)
// -----------------------------------------------------------------------------
class _ProtractorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height;

    // Gradient Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = const LinearGradient(
      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(rect);

    final paintArc = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final paintBg = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw Background
    canvas.drawArc(rect, math.pi, math.pi, true, paintBg);
    
    // Draw Border Gradient
    canvas.drawArc(rect, math.pi, math.pi, false, paintArc);

    // Ticks
    final paintTick = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 180; i += 10) {
      final angle = (180 + i) * (math.pi / 180);
      final isMajor = i % 45 == 0;
      final len = isMajor ? 15.0 : 8.0;
      
      final p1 = Offset(center.dx + math.cos(angle) * (radius - len), center.dy + math.sin(angle) * (radius - len));
      final p2 = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
      
      paintTick.color = isMajor ? Colors.white : Colors.white24;
      paintTick.strokeWidth = isMajor ? 3 : 1;
      canvas.drawLine(p1, p2, paintTick);
    }
    
    // Base Line
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paintTick..color = Colors.white24..strokeWidth=1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
