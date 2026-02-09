import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional utility dashboard card for Survival tools.
/// 
/// This widget displays a clean, modern card for survival tools without
/// any gamification elements (no levels, progress bars, or locked states).
/// All cards are immediately interactive and lead to their respective tool pages.
class SurvivalCard extends StatelessWidget {
  /// Card title (e.g., "🧭 Kompas")
  final String title;

  /// Card subtitle (e.g., "Magnetometer")
  final String subtitle;

  /// Card description (e.g., "Real-time magnetic heading")
  final String description;

  /// Accent color for the card (border, text highlights)
  final Color accentColor;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Live preview widget displayed in the card center
  final Widget? preview;

  /// Background color of the card (defaults to dark tactical blue)
  final Color? backgroundColor;

  /// Icon/emoji displayed prominently
  final String? icon;

  const SurvivalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.onTap,
    this.preview,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF1B2F47);
    const textLight = Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withAlpha(100),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withAlpha(20),
                    accentColor.withAlpha(5),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.robotoMono(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.robotoMono(
                      color: textLight.withAlpha(180),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Live preview widget (center of card)
                  if (preview != null)
                    Expanded(
                      child: Center(child: preview),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Text(
                          icon ?? '⚙️',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    description,
                    style: GoogleFonts.robotoMono(
                      color: textLight.withAlpha(150),
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // TAP TO OPEN hint
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TAP TO OPEN',
                      style: GoogleFonts.robotoMono(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
