import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
  });

  /// Variant for list items
  factory SkeletonLoader.list({Color? baseColor, Color? highlightColor}) {
    return SkeletonLoader(
      width: double.infinity,
      height: 80,
      borderRadius: 12,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Variant for cards or larger blocks
  factory SkeletonLoader.card({double height = 120, Color? baseColor, Color? highlightColor}) {
    return SkeletonLoader(
      width: double.infinity,
      height: height,
      borderRadius: 16,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Variant for avatars/profiles
  factory SkeletonLoader.profile({double size = 80, Color? baseColor, Color? highlightColor}) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Generic block for text or small items
  factory SkeletonLoader.block({double width = 100, double height = 24, Color? baseColor, Color? highlightColor}) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: 4,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default to graphite (dark) for the cyber theme feel
    final bColor = baseColor ?? AppColors.graphite;
    final hColor = highlightColor ?? const Color(0xFF2C2C35); // Lighter graphite

    return Shimmer.fromColors(
      baseColor: bColor,
      highlightColor: hColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer requires a non-transparent color
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
