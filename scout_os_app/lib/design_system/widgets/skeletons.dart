import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../tokens/colors.dart';

/// Primitive skeleton box to build other skeletons.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class NotebookSkeleton extends StatelessWidget {
  const NotebookSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 200, height: 32, borderRadius: 12),
          const SizedBox(height: 24),
          const SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const SkeletonBox(width: 300, height: 16),
          const SizedBox(height: 32),
          const SkeletonBox(width: double.infinity, height: 200, borderRadius: 16),
        ],
      ),
    );
  }
}

class MissionSkeleton extends StatelessWidget {
  const MissionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 150, height: 24, borderRadius: 8),
          const SizedBox(height: 16),
          const SkeletonBox(width: double.infinity, height: 64, borderRadius: 12),
          const SizedBox(height: 24),
          const Expanded(
            child: SkeletonBox(width: double.infinity, height: double.infinity, borderRadius: 16),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonBox(width: 120, height: 48, borderRadius: 24),
            ],
          )
        ],
      ),
    );
  }
}

class JourneySkeleton extends StatelessWidget {
  const JourneySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: NotebookSkeleton(),
      ),
    );
  }
}
