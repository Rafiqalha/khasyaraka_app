import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/core/services/quiz_haptic_service.dart';

class CipherRotorWidget extends StatefulWidget {
  final String encryptedText;
  final Function(int) onChanged;

  const CipherRotorWidget({
    super.key,
    required this.encryptedText,
    required this.onChanged,
  });

  @override
  State<CipherRotorWidget> createState() => _CipherRotorWidgetState();
}

class _CipherRotorWidgetState extends State<CipherRotorWidget> {
  int _currentShift = 0;

  String _decryptText(String text, int shift) {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) { // Uppercase
        // Shift backwards for decryption
        result.writeCharCode(((charCode - 65 - shift + 26) % 26) + 65);
      } else if (charCode >= 97 && charCode <= 122) { // Lowercase
        result.writeCharCode(((charCode - 97 - shift + 26) % 26) + 97);
      } else {
        result.writeCharCode(charCode); // Space, punctuation, etc.
      }
    }
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Real-time Decrypted Text Display
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF16161A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cyberBlue.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyberBlue.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                'LIVE DECRYPTION //',
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cyberBlue.withOpacity(0.8),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _decryptText(widget.encryptedText, _currentShift),
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 3D Cipher Rotor
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF16161A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Highlight bar in the center
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyberBlue.withOpacity(0.5), width: 2),
                ),
              ),
              
              // The Wheel
              ListWheelScrollView.useDelegate(
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  QuizHapticService.selectionFeedback();
                  setState(() {
                    _currentShift = index % 26;
                  });
                  widget.onChanged(_currentShift);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final shiftValue = index % 26;
                    final isSelected = shiftValue == _currentShift;
                    
                    return Center(
                      child: Text(
                        '+$shiftValue',
                        style: GoogleFonts.robotoMono(
                          fontSize: isSelected ? 28 : 20,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: isSelected ? AppColors.cyberBlue : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Text(
          'GESER RODA KE ATAS ATAU KE BAWAH',
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// Custom BoxShadow extension for inset shadow isn't natively supported,
// so let's use a simpler implementation for the shadow or remove `inset: true`.
// Wait, Flutter's BoxShadow doesn't support inset out of the box. 
// I will just use standard BoxShadow and rely on colors for depth.
