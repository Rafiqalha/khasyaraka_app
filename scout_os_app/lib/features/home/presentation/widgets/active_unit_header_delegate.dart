import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';
import '../../data/models/training_path.dart';

/// A SINGLE pinned header that displays the currently active unit.
/// Content updates dynamically based on scroll position.
/// Never stacks, never hides - just replaces content.
class ActiveUnitHeaderDelegate extends SliverPersistentHeaderDelegate {
  final UnitModel unit;
  final int sectionIndex;
  final int unitNumber; // Explicit unit number (1-10) instead of global orderIndex
  final Color color;
  final double height;

  ActiveUnitHeaderDelegate({
    required this.unit,
    required this.sectionIndex,
    required this.unitNumber,
    required this.color,
    this.height = 90.0,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate lip color (darker version of the main color)
    final HSLColor hsl = HSLColor.fromColor(color);
    final double darkerLightness = (hsl.lightness - 0.15).clamp(0.0, 1.0);
    final Color lipColor = hsl.withLightness(darkerLightness).toColor();

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced from 8 to 4
        child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: lipColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Reduced from 12 to 6
        margin: const EdgeInsets.only(bottom: 4), 
        child: Row(
          children: [
            // Left Content (Text)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge Text
                  Text(
                    "BAGIAN $sectionIndex, UNIT $unitNumber",
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Title Text
                  Text(
                    unit.title,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Vertical Divider
            Container(
              width: 1.5,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.black.withOpacity(0.1),
            ),

            // Right Icon (Guidebook)
            const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    ));
  }

  // Update Max Extent to fit the new taller 3D header
  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant ActiveUnitHeaderDelegate oldDelegate) {
    return true; // Always rebuild to prevent semantics bounds mismatches
  }
}
