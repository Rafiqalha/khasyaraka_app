import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_text_styles.dart';

class UnitHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String description;
  final Color color;
  final int orderIndex;

  UnitHeaderDelegate({
    required this.title,
    required this.description,
    required this.color,
    required this.orderIndex,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate how "pinned" we are (0.0 = fully expanded, 1.0 = fully shrunk)
    final double shrinkRatio = shrinkOffset / (maxExtent - minExtent);
    final double clampedRatio = shrinkRatio.clamp(0.0, 1.0);

    // Darken color slightly when pinned for depth
    final Color headerColor = Color.lerp(
      color,
      color.withOpacity(0.95),
      clampedRatio,
    )!;

    // Shadow increases when pinned
    final double shadowOpacity = 0.1 + (clampedRatio * 0.15);
    final double shadowBlur = 4.0 + (clampedRatio * 12.0);

    return Container(
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(clampedRatio > 0.5 ? 0 : 20),
          bottomRight: Radius.circular(clampedRatio > 0.5 ? 0 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity),
            blurRadius: shadowBlur,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Subtle overlay)
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.shield_rounded,
                size: 120 - (shrinkOffset * 0.3),
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "BAGIAN X, UNIT Y" label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          description,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        title,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontSize:
                              20 -
                              (clampedRatio *
                                  2), // Slightly smaller when pinned
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Guidebook button
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120.0;

  @override
  double get minExtent => 90.0;

  @override
  bool shouldRebuild(covariant UnitHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.color != color ||
        oldDelegate.description != description ||
        oldDelegate.orderIndex != orderIndex;
  }
}
