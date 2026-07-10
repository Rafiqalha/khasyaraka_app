import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ NEW
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/core/services/quiz_haptic_service.dart';

class LogAnomalyWidget extends StatelessWidget {
  final List<String> lines;
  final int? selectedIndex;
  final bool isChecked;
  final bool isCorrect;
  final int? correctIndex;
  final Function(int) onLineSelected;

  const LogAnomalyWidget({
    super.key,
    required this.lines,
    required this.selectedIndex,
    required this.isChecked,
    required this.isCorrect,
    this.correctIndex,
    required this.onLineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // The 3D Perspective container
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Transform(
        // Matrix4 to create a 3D tilt effect (leaning backwards)
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(-0.15), // tilt back slightly
        alignment: FractionalOffset.center,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F12), // Very dark terminal background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cyberBlue.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyberBlue.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Grid overlay for cyber feel
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),
              ),
              
              // Terminal content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Terminal Header
                    Row(
                      children: [
                        const Icon(Icons.terminal, color: AppColors.cyberBlue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'SERVER_LOG_STREAM // ANALYZE_MODE',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cyberBlue.withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2A2A35), height: 1),
                    const SizedBox(height: 16),
                    
                    // Log Lines
                    ...List.generate(lines.length, (index) {
                      final line = lines[index];
                      final isSelected = selectedIndex == index;
                      
                      // Logic for colors after check
                      Color bgColor = Colors.transparent;
                      Color textColor = Colors.white70;
                      Color borderColor = Colors.transparent;
                      
                      if (isChecked) {
                        if (index == correctIndex) {
                          // This is the correct line (whether user picked it or not)
                          bgColor = AppColors.duoSuccess.withOpacity(0.2);
                          textColor = AppColors.duoSuccess;
                          borderColor = AppColors.duoSuccess.withOpacity(0.5);
                        } else if (isSelected && !isCorrect) {
                          // User picked this, but it's wrong
                          bgColor = AppColors.alertRed.withOpacity(0.2);
                          textColor = AppColors.alertRed;
                          borderColor = AppColors.alertRed.withOpacity(0.5);
                        }
                      } else if (isSelected) {
                        // User selected this, not yet checked
                        bgColor = AppColors.cyberBlue.withOpacity(0.15);
                        textColor = AppColors.cyberBlue;
                        borderColor = AppColors.cyberBlue;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!isChecked) {
                            HapticFeedback.lightImpact();
                            onLineSelected(index);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Text(
                            line,
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: textColor,
                              height: 1.3,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyberBlue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    const step = 20.0;
    
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
