import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scout_os_app/features/home/data/models/incident.dart';

class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onEngage;

  const IncidentCard({super.key, required this.incident, required this.onEngage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEngage,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '[THREAT: LV.${incident.difficultyLevel}] // ${incident.toolLabel}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8B949E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              incident.question,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC9D1D9),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '+${incident.xp} XP',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B949E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
