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
  final Color color;
  final double height;

  ActiveUnitHeaderDelegate({
    required this.unit,
    required this.sectionIndex,
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
    // Calculate lip color (darker version of the main color)
    final HSLColor hsl = HSLColor.fromColor(color);
    final double darkerLightness = (hsl.lightness - 0.15).clamp(0.0, 1.0);
    final Color lipColor = hsl.withLightness(darkerLightness).toColor();

    return Container(
      // Outer container transparent to let shadow/lip show
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. LIP (Bottom Layer)
          Positioned(
            top: 4, // Shifted down to create depth
            left: 0,
            right: 0,
            bottom: -4,
            child: Container(
              decoration: BoxDecoration(
                color: lipColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // 2. FACE (Top Layer)
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                        "BAGIAN $sectionIndex, UNIT ${unit.orderIndex}",
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w800,
                        ),
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
        ],
      ),
    );
  }

  // Update Max Extent to fit the new taller 3D header
  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant ActiveUnitHeaderDelegate oldDelegate) {
    return oldDelegate.unit.id != unit.id ||
        oldDelegate.sectionIndex != sectionIndex ||
        oldDelegate.color != color ||
        oldDelegate.height != height;
  }
}
