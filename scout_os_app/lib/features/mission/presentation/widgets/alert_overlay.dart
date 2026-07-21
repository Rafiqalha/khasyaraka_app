import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int timeRemaining;
  final int score;

  const AlertOverlay({super.key, required this.events, required this.timeRemaining, required this.score});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF30363D))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.shield, color: Color(0xFFD29922), size: 14),
            const SizedBox(width: 6),
            Text('$score pts', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFD29922), fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 6),
        ...events.take(4).map((e) {
          final sev = e['severity'] ?? 'info';
          final color = sev == 'critical' ? const Color(0xFFF85149) : sev == 'high' ? const Color(0xFFFF9600) : const Color(0xFF58A6FF);
          final icon = sev == 'critical' ? Icons.warning : sev == 'high' ? Icons.error_outline : Icons.info_outline;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF0D1117).withAlpha(230), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withAlpha(80))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 6),
                Flexible(child: Text(e['message'] ?? '', style: GoogleFonts.plusJakartaSans(color: color, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}
