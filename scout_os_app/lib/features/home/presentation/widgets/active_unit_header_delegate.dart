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

  ActiveUnitHeaderDelegate({
    required this.unit,
    required this.sectionIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        "BAGIAN $sectionIndex • UNIT ${unit.orderIndex}",
                        key: ValueKey("badge-$sectionIndex-${unit.orderIndex}"),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title with smooth transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      unit.title,
                      key: ValueKey("title-${unit.id}"),
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Guidebook icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70.0;

  @override
  double get minExtent => 70.0;

  @override
  bool shouldRebuild(covariant ActiveUnitHeaderDelegate oldDelegate) {
    return oldDelegate.unit.id != unit.id ||
           oldDelegate.sectionIndex != sectionIndex ||
           oldDelegate.color != color;
  }
}
