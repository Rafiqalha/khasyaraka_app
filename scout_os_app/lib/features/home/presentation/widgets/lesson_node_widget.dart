import 'package:flutter/material.dart';
import 'package:scout_os_app/shared/theme/app_colors.dart';
import '../../data/models/training_path.dart';

class LessonNodeWidget extends StatefulWidget {
  final LessonNode lesson;
  final Color unitColor;
  final VoidCallback onTap;

  const LessonNodeWidget({
    super.key,
    required this.lesson,
    required this.unitColor,
    required this.onTap,
  });

  @override
  State<LessonNodeWidget> createState() => _LessonNodeWidgetState();
}

class _LessonNodeWidgetState extends State<LessonNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _updatePulseAnimation();
  }

  @override
  void didUpdateWidget(LessonNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // CRITICAL: Update pulse animation when lesson status changes
    if (oldWidget.lesson.status != widget.lesson.status) {
      _updatePulseAnimation();
    }
  }

  void _updatePulseAnimation() {
    final status = widget.lesson.status; // Already uppercase from model
    final isActive = status == 'ACTIVE' || 
                     status == 'UNLOCKED' ||
                     (status != 'LOCKED' && status != 'COMPLETED' && status.isNotEmpty);
    
    if (isActive) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Strict 3-state logic (UPPERCASE)
    final status = widget.lesson.status.toUpperCase(); // Double check normalization
    final isPlayable = status == 'UNLOCKED' || status == 'COMPLETED';
    final shouldAnimate = status == 'UNLOCKED'; // Only bounce current active level

    return GestureDetector(
      onTap: isPlayable ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: shouldAnimate ? _pulseAnimation.value : 1.0,
            child: _buildNodeContent(status),
          );
        },
      ),
    );
  }

  Widget _buildNodeContent(String status) {
    const nodeSize = 72.0;
    Widget node;
    
    // Strict Switch Case as requested (UPPERCASE)
    switch (status) {
      case 'COMPLETED':
        node = _buildCompletedNode(size: nodeSize);
        break;
      case 'UNLOCKED':
        node = _buildActiveNode(size: nodeSize, glow: true);
        break;
      case 'LOCKED':
      default:
        node = _buildLockedNode(size: nodeSize);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        node,
        const SizedBox(height: 6),
        _buildLabel(),
      ],
    );
  }

  // Helper method to keep UI clean - old buildNodeContent removed
  Widget _buildLabel() {
     return Text(
          'Level ${widget.lesson.orderIndex}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        );
  }

  Widget _buildLockedNode({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5), // Light grey for locked
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFBDBDBD), width: 4), // Thicker border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.lock_rounded, size: 30, color: const Color(0xFF9E9E9E)),
      ),
    );
  }

  Widget _buildActiveNode({required double size, required bool glow}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50), // ✅ Green for UNLOCKED (Active)
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: glow ? 0.6 : 0.3),
            blurRadius: glow ? 16 : 8,
            spreadRadius: glow ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded, // ✅ Star icon for active
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCompletedNode({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Gold for completed
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFBC02D), width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Optional: Star background or just simple gold circle
          Icon(
            Icons.check_rounded, // ✅ Checkmark for completed
            size: 40,
            color: Colors.white, // Or darker gold
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Icon(Icons.star, size: 10, color: Colors.white.withValues(alpha: 0.5)),
          )
        ],
      ),
    );
  }
}
