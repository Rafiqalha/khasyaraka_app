import 'package:flutter/material.dart';
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
    final status = widget.lesson.status;
    final isActive = status == 'active' || 
                     status == 'unlocked' ||
                     (status != 'locked' && status != 'completed' && status.isNotEmpty);
    
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
    // CRITICAL FIX: Recognize 'active', 'unlocked', and 'completed' as playable states
    // Only 'locked' (or empty) should be considered locked
    final status = widget.lesson.status;
    final isActive = status == 'active' || 
                     status == 'unlocked' ||
                     (status != 'locked' && status != 'completed' && status.isNotEmpty);
    final isCompleted = status == 'completed';
    final isLocked = status == 'locked' || status.isEmpty;

    return GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? _pulseAnimation.value : 1.0,
            child: _buildNodeContent(isActive, isCompleted, isLocked),
          );
        },
      ),
    );
  }

  Widget _buildNodeContent(bool isActive, bool isCompleted, bool isLocked) {
    const nodeSize = 72.0;

    final node = isLocked
        ? _buildLockedNode(size: nodeSize)
        : isCompleted
            ? _buildCompletedNode(size: nodeSize)
            : _buildActiveNode(size: nodeSize, glow: isActive);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        node,
        const SizedBox(height: 6),
        Text(
          'Level ${widget.lesson.orderIndex}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedNode({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFB0BEC5).withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF90A4AE), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: UnconstrainedBox(
        child: Icon(Icons.lock_rounded, size: 30, color: Colors.blueGrey.shade700),
      ),
    );
  }

  Widget _buildActiveNode({required double size, required bool glow}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: glow ? 0.5 : 0.3),
            blurRadius: glow ? 20 : 12,
            spreadRadius: glow ? 2 : 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: UnconstrainedBox(
        child: Icon(
          Icons.park_rounded,
          size: 34,
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
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1B5E20), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: UnconstrainedBox(
        child: Icon(
          Icons.check_circle,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}
