import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';

/// Shimmer skeleton for training map loading state
///
/// Shows animated placeholders that match the actual UI layout:
/// - Stats bar at top
/// - Section cards
/// - Lesson nodes in zigzag pattern
class ShimmerTrainingMap extends StatelessWidget {
  const ShimmerTrainingMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats bar skeleton
            const ShimmerStatsBar(),
            const SizedBox(height: 24),

            // Section card skeleton
            const ShimmerSectionCard(),
            const SizedBox(height: 16),

            // Unit header skeleton
            const ShimmerUnitHeader(),
            const SizedBox(height: 24),

            // Lesson nodes skeleton (zigzag pattern)
            ...List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(
                  left: index.isEven ? 40 : 120,
                  right: index.isEven ? 120 : 40,
                  bottom: 20,
                ),
                child: const ShimmerLessonNode(),
              ),
            ),

            const SizedBox(height: 32),

            // Second section preview
            const ShimmerSectionCard(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for stats bar (XP, Streak, Hearts)
class ShimmerStatsBar extends StatelessWidget {
  const ShimmerStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(),
          _verticalDivider(),
          _buildStatItem(),
          _verticalDivider(),
          _buildStatItem(),
        ],
      ),
    );
  }

  Widget _buildStatItem() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 32,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 32, color: Colors.grey[300]);
  }
}

/// Skeleton for section card header
class ShimmerSectionCard extends StatelessWidget {
  const ShimmerSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label pill
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for unit header
class ShimmerUnitHeader extends StatelessWidget {
  const ShimmerUnitHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 180,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Skeleton for lesson node (circular button)
class ShimmerLessonNode extends StatelessWidget {
  const ShimmerLessonNode({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!, width: 3),
        ),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
