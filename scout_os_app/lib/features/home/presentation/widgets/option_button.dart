import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isChecked;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isChecked,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA WARNA ---
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Color textColor = AppColors.textDark;

    if (isChecked) {
      if (isCorrectAnswer) {
        // Jawaban Benar (Hijau)
        borderColor = AppColors.forestGreen;
        bgColor = AppColors.forestGreen.withValues(alpha: 0.1);
        textColor = AppColors.forestGreen;
      } else if (isSelected && !isCorrectAnswer) {
        // Jawaban Salah yang dipilih User (Merah)
        borderColor = AppColors.alertRed;
        bgColor = AppColors.alertRed.withValues(alpha: 0.1);
        textColor = AppColors.alertRed;
      }
    } else if (isSelected) {
      // Sedang dipilih tapi belum dicek (Biru/Default Active)
      borderColor = AppColors.actionOrange;
      bgColor = AppColors.actionOrange.withValues(alpha: 0.1);
      textColor = AppColors.textDark; // Tetap gelap biar kontras
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isChecked ? null : onTap, // Disable klik kalau sudah dicek
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            // Efek bayangan tipis di bawah (3D style)
            boxShadow: isSelected && !isChecked 
                ? [BoxShadow(color: borderColor, offset: const Offset(0, 2))]
                : [],
          ),
          child: Row(
            children: [
              // Kotak Huruf (A, B, C, D)
              Container(
                width: 32, 
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // 0->A, 1->B, dst
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Teks Jawaban
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              // Icon Status (Opsional, muncul pas dicek)
              if (isChecked && isCorrectAnswer)
                Icon(Icons.check_circle, color: AppColors.forestGreen),
              if (isChecked && isSelected && !isCorrectAnswer)
                Icon(Icons.cancel, color: AppColors.alertRed),
            ],
          ),
        ),
      ),
    );
  }
}