import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final bgColor = isCorrect
        ? const Color(0xFFD7FFB8)
        : const Color(0xFFFFDFE0); // Lighter variants
    final contentColor = isCorrect ? AppColors.duoSuccess : AppColors.duoError;
    final buttonColor = isCorrect ? AppColors.duoSuccess : AppColors.duoError;
    final shadowColor = isCorrect
        ? AppColors.duoSuccessShadow
        : AppColors.duoErrorShadow;

    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final titleText = isCorrect ? "Benar!" : "Kurang Tepat";

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Icon + Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: contentColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      titleText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Content for Incorrect Answer
                if (!isCorrect && correctAnswer != null) ...[
                  Text(
                    "Jawaban yang benar:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    correctAnswer!,
                    style: TextStyle(fontSize: 18, color: contentColor),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  const SizedBox(height: 24),
                ],

                // Continue Button (Full Width)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0, // Custom shadow
                      ),
                      child: const Text(
                        "LANJUTKAN",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .moveY(
          begin: 100,
          end: 0,
          duration: 400.ms,
          curve: Curves.elasticOut,
        ) // Bouncing entry
        .fadeIn(duration: 200.ms);
  }
}
