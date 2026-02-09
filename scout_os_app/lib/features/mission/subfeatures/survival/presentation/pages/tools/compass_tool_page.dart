import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';

class CompassToolPage extends StatefulWidget {
  const CompassToolPage({super.key});

  @override
  State<CompassToolPage> createState() => _CompassToolPageState();
}

class _CompassToolPageState extends State<CompassToolPage> {
  // Theme Colors (Tactical Cyan -> Deep Blue)
  static const Color _cyanAccent = Colors.cyanAccent;
  static const Color _deepBlue = Color(0xFF0D47A1); // Blue[900]
  static const Color _glassWhite = Colors.white;
  static const Color _tacticalRed = Color(0xFFFF5252);

  // State
  bool _isLocked = false;
  double? _lockedHeading;
  double? _currentHeading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'TACTICAL COMPASS',
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_cyanAccent, _deepBlue],
          ),
        ),
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            // Error / Loading State
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error reading sensors',
                  style: GoogleFonts.fredoka(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            double? heading = snapshot.data?.heading;

            // Handle Lock Logic
            if (_isLocked && _lockedHeading != null) {
              heading = _lockedHeading;
            } else {
              _currentHeading = heading;
            }

            if (heading == null) {
               return Center(
                child: Text(
                  'Hardware unsupported',
                  style: GoogleFonts.fredoka(color: Colors.white),
                ),
              );
            }
            
            // Calculations
            final normalizedHeading = (heading + 360) % 360;
            final backAzimuth = (normalizedHeading + 180) % 360;
            final direction = _cardinalDirection(normalizedHeading);

            return SafeArea(
              child: Column(
                children: [
                   const SizedBox(height: 20),
                   
                   // -----------------------------------------------------------
                   // A. FLOATING DASHBOARD (Glassmorphism)
                   // -----------------------------------------------------------
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                       decoration: BoxDecoration(
                         color: _glassWhite.withOpacity(0.9),
                         borderRadius: BorderRadius.circular(24),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.2),
                             blurRadius: 20,
                             offset: const Offset(0, 10),
                           ),
                         ],
                       ),
                       child: Column(
                         children: [
                           // Row 1: Labels
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 'AZIMUTH',
                                 style: GoogleFonts.fredoka(
                                   color: Colors.grey[600],
                                   fontSize: 12,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                               Text(
                                 'BACK AZIMUTH',
                                 style: GoogleFonts.fredoka(
                                   color: Colors.grey[600],
                                   fontSize: 12,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 8),
                           
                           // Row 2: Values (The Big Numbers)
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               // Azimuth + Direction
                               Row(
                                 crossAxisAlignment: CrossAxisAlignment.baseline,
                                 textBaseline: TextBaseline.alphabetic,
                                 children: [
                                   Text(
                                     normalizedHeading.toStringAsFixed(0),
                                     style: GoogleFonts.fredoka(
                                       fontSize: 48,
                                       fontWeight: FontWeight.w700, // Bold
                                       color: Colors.black87,
                                       height: 1.0,
                                     ),
                                   ),
                                   Text(
                                     '°',
                                      style: GoogleFonts.fredoka(
                                       fontSize: 48,
                                       fontWeight: FontWeight.w300,
                                       color: Colors.black54,
                                       height: 1.0,
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Text(
                                     direction,
                                     style: GoogleFonts.fredoka(
                                       fontSize: 24,
                                       fontWeight: FontWeight.w600,
                                       color: _deepBlue,
                                     ),
                                   ),
                                 ],
                               ),
                               
                               // Back Azimuth Value
                               Text(
                                 '${backAzimuth.toStringAsFixed(0)}°',
                                  style: GoogleFonts.fredoka(
                                   fontSize: 28,
                                   fontWeight: FontWeight.w600,
                                   color: _tacticalRed, // Red Bata
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                   ),
                   
                   const Spacer(),

                   // -----------------------------------------------------------
                   // B. VISUAL COMPASS (The Dial)
                   // -----------------------------------------------------------
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: AspectRatio(
                       aspectRatio: 1,
                       child: Stack(
                         alignment: Alignment.center,
                         children: [
                           // 1. Static Outer Ring (Optional Decor)
                           Container(
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                             ),
                           ),
                           
                           // 2. Rotating Compass Rose
                           Transform.rotate(
                             angle: -normalizedHeading * (math.pi / 180),
                             child: _TacticalCompassPainter(),
                           ),

                           // 3. Static Indicator Needle (Red Line at Top)
                           Positioned(
                             top: 20,
                             child: Container(
                               width: 4,
                               height: 40,
                               decoration: BoxDecoration(
                                 color: _tacticalRed,
                                 borderRadius: BorderRadius.circular(4),
                                 boxShadow: [
                                   BoxShadow(
                                     color: _tacticalRed.withOpacity(0.6),
                                     blurRadius: 8,
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),

                   const Spacer(),

                   // -----------------------------------------------------------
                   // C. LOCK BEARING BUTTON (3D Style)
                   // -----------------------------------------------------------
                   Padding(
                     padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
                     child: GestureDetector(
                       onTap: () {
                         HapticFeedback.mediumImpact();
                         setState(() {
                           if (_isLocked) {
                             _isLocked = false;
                             _lockedHeading = null;
                           } else {
                             _isLocked = true;
                             _lockedHeading = _currentHeading;
                           }
                         });
                       },
                       child: AnimatedContainer(
                         duration: const Duration(milliseconds: 150),
                         height: 60,
                         decoration: BoxDecoration(
                           color: _isLocked ? _tacticalRed : Colors.white,
                           borderRadius: BorderRadius.circular(30),
                           border: Border(
                             bottom: BorderSide(
                               color: _isLocked ? const Color(0xFFB71C1C) : Colors.grey.shade400, // 3D Shadow
                               width: 6.0,
                             ),
                           ),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.2),
                               blurRadius: 10,
                               offset: const Offset(0, 5),
                             ),
                           ],
                         ),
                         child: Center(
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 _isLocked ? Icons.lock : Icons.lock_open,
                                 color: _isLocked ? Colors.white : _deepBlue,
                               ),
                               const SizedBox(width: 12),
                               Text(
                                 _isLocked ? 'UNLOCK BEARING' : 'LOCK BEARING',
                                 style: GoogleFonts.fredoka(
                                   color: _isLocked ? Colors.white : _deepBlue,
                                   fontSize: 18,
                                   fontWeight: FontWeight.w700,
                                   letterSpacing: 1.0,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  String _cardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

// -----------------------------------------------------------------------------
// TACTICAL COMPASS PAINTER
// -----------------------------------------------------------------------------
class _TacticalCompassPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _CompassFacePainter(),
    );
  }
}

class _CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20; // Padding

    final paintMain = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintSecondary = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw Ticks
    for (int i = 0; i < 360; i += 2) {
      final angle = (i - 90) * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 10 == 0;
      
      final double outer = radius;
      final double inner = isCardinal ? radius - 20 : (isMajor ? radius - 12 : radius - 6);

      final p1 = Offset(center.dx + math.cos(angle) * inner, center.dy + math.sin(angle) * inner);
      final p2 = Offset(center.dx + math.cos(angle) * outer, center.dy + math.sin(angle) * outer);

      canvas.drawLine(p1, p2, isMajor ? paintMain : paintSecondary);

      // Draw Numbers every 30 degrees
      if (i % 30 == 0 && i % 90 != 0) {
        textPainter.text = TextSpan(
          text: '$i',
          style: GoogleFonts.fredoka(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        
        // Position info text slightly inside
        final textRadius = radius - 35;
        final textOffset = Offset(
           center.dx + math.cos(angle) * textRadius - textPainter.width / 2,
           center.dy + math.sin(angle) * textRadius - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw Cardinals (N, E, S, W)
    final cardinals = {'N': 0, 'E': 90, 'S': 180, 'W': 270};
    cardinals.forEach((label, degree) {
       final angle = (degree - 90) * math.pi / 180;
       final textRadius = radius - 45;
       
       textPainter.text = TextSpan(
          text: label,
          style: GoogleFonts.fredoka(
            color: label == 'N' ? const Color(0xFFFF5252) : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        final textOffset = Offset(
           center.dx + math.cos(angle) * textRadius - textPainter.width / 2,
           center.dy + math.sin(angle) * textRadius - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
