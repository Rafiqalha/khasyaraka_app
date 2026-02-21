import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';

class CyberContainer extends StatelessWidget {
  const CyberContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.isLocked = false,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool isLocked;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = isLocked
        ? CyberTheme.textSecondary.withValues(alpha: 0.3)
        : (glowColor ?? CyberTheme.neonCyan).withValues(alpha: 0.5);
    final shadowColor = isLocked
        ? CyberTheme.textSecondary.withValues(alpha: 0.1)
        : (glowColor ?? CyberTheme.neonCyan).withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 12, spreadRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
