import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;

  const QuestionCard({super.key, required this.questionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        questionText,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          height: 1.3, // Spasi antar baris biar mudah dibaca
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}