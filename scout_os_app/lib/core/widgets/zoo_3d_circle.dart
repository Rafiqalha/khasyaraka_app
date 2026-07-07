import 'package:flutter/material.dart';

enum Zoo3DCircleStyle {
  duolingo,
  sphere,
  ring,
}

class Zoo3DCircle extends StatefulWidget {
  final double size;
  final Color color;
  final Widget child;
  final VoidCallback? onPressed;
  final Zoo3DCircleStyle style;
  final double depth;
  final bool glowing;
  final Color? shadowColor;

  const Zoo3DCircle({
    super.key,
    required this.size,
    required this.color,
    required this.child,
    this.onPressed,
    this.style = Zoo3DCircleStyle.duolingo,
    this.depth = 6.0,
    this.glowing = false,
    this.shadowColor,
  });

  @override
  State<Zoo3DCircle> createState() => _Zoo3DCircleState();
}

class _Zoo3DCircleState extends State<Zoo3DCircle>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _tapController;
  late Animation<double> _depressionAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _depressionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Color get _shadowColor {
    if (widget.shadowColor != null) return widget.shadowColor!;
    final HSLColor hsl = HSLColor.fromColor(widget.color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.onPressed != null
          ? (_) {
              if (!_isPressed) {
                setState(() => _isPressed = true);
                _tapController.forward();
              }
            }
          : null,
      onPointerUp: widget.onPressed != null
          ? (_) {
              if (_isPressed) {
                setState(() => _isPressed = false);
                _tapController.reverse();
              }
            }
          : null,
      onPointerCancel: widget.onPressed != null
          ? (_) {
              if (_isPressed) {
                setState(() => _isPressed = false);
                _tapController.reverse();
              }
            }
          : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
        animation: _depressionAnimation,
        builder: (context, _) {
          final depression = _depressionAnimation.value;

          Widget content;
          switch (widget.style) {
            case Zoo3DCircleStyle.duolingo:
              content = _buildDuolingoStyle(depression);
              break;
            case Zoo3DCircleStyle.sphere:
              content = _buildSphereStyle(depression);
              break;
            case Zoo3DCircleStyle.ring:
              content = _buildRingStyle(depression);
              break;
          }

          if (widget.glowing) {
            content = Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                content,
              ],
            );
          }

          return SizedBox(
            height: widget.style == Zoo3DCircleStyle.sphere
                ? widget.size
                : widget.size + widget.depth,
            width: widget.size,
            child: content,
          );
        },
      ),
    ),
  );
  }

  Widget _buildDuolingoStyle(double depression) {
    final double currentOffset = widget.depth * depression;

    final Widget face = Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
      ),
      child: Center(child: widget.child),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lip
        Positioned(
          top: widget.depth,
          child: Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              color: _shadowColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Face
        Positioned(
          top: currentOffset,
          child: face,
        ),
      ],
    );
  }

  Widget _buildSphereStyle(double depression) {
    final double scale = 1.0 - (0.05 * depression); // Slight scale down on press

    return Transform.scale(
      scale: scale,
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.8,
            colors: [
              Colors.white.withOpacity(0.4),
              widget.color,
              _shadowColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }

  Widget _buildRingStyle(double depression) {
    final double currentOffset = widget.depth * depression;

    final Widget face = Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.color,
          width: 6.0,
        ),
        color: Colors.white,
      ),
      child: Center(child: widget.child),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lip (Border shadow)
        Positioned(
          top: widget.depth,
          child: Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _shadowColor,
                width: 6.0,
              ),
              color: Colors.transparent,
            ),
          ),
        ),
        // Face
        Positioned(
          top: currentOffset,
          child: face,
        ),
      ],
    );
  }
}
