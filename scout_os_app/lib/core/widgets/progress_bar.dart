import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class ScoutProgressBar extends StatelessWidget {
  final double value; // 0.0 sampai 1.0
  final double height;
  final Color color;
  final Color? backgroundColor;

  const ScoutProgressBar({
    super.key,
    required this.value,
    this.height = 12,
    this.color = AppColors.forestGreen,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor:
            backgroundColor ?? AppColors.textGrey.withValues(alpha: 0.2),
        color: color,
      ),
    );
  }
}
