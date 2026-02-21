import 'dart:ui';

import 'package:flutter/material.dart';

class GlossyStatsBar extends StatelessWidget {
  const GlossyStatsBar({
    super.key,
    required this.streak,
    required this.totalXp,
  });

  final int streak;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlossyCapsule(
          customIcon: Image.asset(
            'assets/icons/training/fire.png',
            height: 22,
            width: 22,
          ),
          value: '$streak',
          label: 'Streak',
          borderColor: const Color(0xFFFFA726),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFFD54F)],
          ),
        ),
        const SizedBox(width: 12),
        _GlossyCapsule(
          customIcon: Image.asset(
            'assets/icons/training/star.png',
            height: 22,
            width: 22,
          ),
          value: _formatXp(totalXp),
          label: 'XP',
          borderColor: const Color(0xFFFFD600),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFFFFD700)],
          ),
        ),
      ],
    );
  }

  static String _formatXp(int xp) {
    if (xp >= 1000) {
      final value = (xp / 1000).toStringAsFixed(1).replaceAll('.0', '');
      return '${value}K';
    }
    return xp.toString();
  }
}

class _GlossyCapsule extends StatelessWidget {
  const _GlossyCapsule({
    this.icon,
    this.customIcon,
    required this.value,
    required this.label,
    required this.borderColor,
    required this.iconGradient,
  });

  final IconData? icon;
  final Widget? customIcon;
  final String value;
  final String label;
  final Color borderColor;
  final LinearGradient iconGradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.25),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customIcon != null)
                customIcon!
              else
                _GradientIcon(icon: icon!, gradient: iconGradient),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({required this.icon, required this.gradient});

  final IconData icon;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Icon(icon, size: 22, color: Colors.white),
    );
  }
}
