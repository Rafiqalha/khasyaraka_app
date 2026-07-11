import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // Log Lines (3D Cards)
          ...List.generate(lines.length, (index) {
            final line = lines[index];
            final isSelected = selectedIndex == index;
            
            // Logic for colors
            Color faceColor = AppColors.deepCharcoal;
            Color lipColor = Colors.black.withOpacity(0.5);
            Color textColor = Colors.white70;
            Color borderColor = Colors.white.withOpacity(0.1);
            
            if (isChecked) {
              if (index == correctIndex) {
                faceColor = AppColors.duoSuccess.withOpacity(0.2);
                lipColor = AppColors.duoSuccess.withOpacity(0.4);
                textColor = AppColors.duoSuccess;
                borderColor = AppColors.duoSuccess;
              } else if (isSelected && !isCorrect) {
                faceColor = AppColors.alertRed.withOpacity(0.2);
                lipColor = AppColors.alertRed.withOpacity(0.4);
                textColor = AppColors.alertRed;
                borderColor = AppColors.alertRed;
              }
            } else if (isSelected) {
              faceColor = AppColors.cyberBlue.withOpacity(0.15);
              lipColor = AppColors.cyberBlue.withOpacity(0.3);
              textColor = AppColors.cyberBlue;
              borderColor = AppColors.cyberBlue;
            }

            return GestureDetector(
              onTap: () {
                if (!isChecked) {
                  QuizHapticService.selectionFeedback();
                  onLineSelected(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: lipColor, // Bottom lip
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, isSelected ? 2 : 0, 0), // Push down when selected
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: faceColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Status Icon
                      if (isChecked && index == correctIndex)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.check_circle_rounded, color: AppColors.duoSuccess, size: 24),
                        )
                      else if (isChecked && isSelected && !isCorrect)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.cancel_rounded, color: AppColors.alertRed, size: 24),
                        )
                      else if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.radio_button_checked_rounded, color: AppColors.cyberBlue, size: 24),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.radio_button_unchecked_rounded, color: Colors.white.withOpacity(0.3), size: 24),
                        ),
                        
                      // Log Text
                      Expanded(
                        child: Text(
                          line,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
