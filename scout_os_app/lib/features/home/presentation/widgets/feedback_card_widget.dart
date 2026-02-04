import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class FeedbackCardWidget extends StatelessWidget {
  final bool isCorrect;
  final String? explanation;
  final VoidCallback onContinue;

  const FeedbackCardWidget({
    super.key,
    required this.isCorrect,
    this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.forestGreen.withValues(alpha: 0.1)
            : AppColors.alertRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? AppColors.forestGreen : AppColors.alertRed,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppColors.forestGreen : AppColors.alertRed)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            size: 64,
            color: isCorrect ? AppColors.forestGreen : AppColors.alertRed,
          ),
          const SizedBox(height: 16),
          Text(
            isCorrect ? "Benar!" : "Salah",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isCorrect ? AppColors.forestGreen : AppColors.alertRed,
            ),
          ),
          if (explanation != null && explanation!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              explanation!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect
                    ? AppColors.forestGreen
                    : AppColors.alertRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Lanjutkan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
