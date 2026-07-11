import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
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
            color: Colors.black.withOpacity(0.5), // Lip shadow base
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6), // 3D Flat Lip
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.deepCharcoal,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [

                Text(
                  _decryptText(widget.encryptedText, _currentShift),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 3D Cipher Rotor
        Container(
          height: 180, // Slightly taller for more elegance
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), // Base Lip
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF16161A), // Darker face to simulate depth
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight bar in the center
                Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cyberBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cyberBlue.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyberBlue.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
                
                // The Wheel
                ListWheelScrollView.useDelegate(
                  itemExtent: 60,
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
                          style: AppTextStyles.h1.copyWith(
                            fontSize: isSelected ? 32 : 24,
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
        ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.unfold_more_rounded, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(
              'GESER RODA UNTUK MENGUBAH SANDI',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
