import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/mission/subfeatures/cyber/presentation/theme/cyber_theme.dart';

class HoloButton extends StatelessWidget {
  const HoloButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("BEEP: cyber execute");
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CyberTheme.primary, width: 1),
          gradient: LinearGradient(
            colors: [
              CyberTheme.surface.withValues(alpha: 0.9),
              CyberTheme.primary.withValues(alpha: 0.15),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: CyberTheme.primary.withValues(alpha: 0.25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.firaCode(
              color: CyberTheme.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
