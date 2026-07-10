import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';

class QuizFeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final String? correctAnswer;
  final VoidCallback onContinue;

  const QuizFeedbackSheet({
    super.key,
    required this.isCorrect,
    this.correctAnswer,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Theme colors based on correctness
    final bgColor = const Color(0xFF242424); // charcoalSurface
    final headerColor = const Color(0xFF161616); // deepCharcoal
    
    final iconColor = isCorrect ? AppColors.duoSuccess : AppColors.duoError;
    final shadowColor = isCorrect ? AppColors.duoSuccessShadow : AppColors.duoErrorShadow;
    
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final titleText = isCorrect ? "Luar Biasa!" : "Kurang Tepat";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Premium Header with 3D Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 32, bottom: 24),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // 3D Icon Container
                  Container(
                    decoration: BoxDecoration(
                      color: shadowColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            
            // Content & Action Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  if (!isCorrect && correctAnswer != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Jawaban yang benar:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            correctAnswer!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  DuoButton(
                    text: 'LANJUTKAN',
                    onPressed: onContinue,
                    variant: isCorrect ? DuoButtonVariant.green : DuoButtonVariant.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().moveY(
      begin: 100,
      end: 0,
      duration: 400.ms,
      curve: Curves.elasticOut,
    ).fadeIn(duration: 200.ms);
  }
}
