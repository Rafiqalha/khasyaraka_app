import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XpPopupWidget extends StatefulWidget {
  const XpPopupWidget({
    super.key,
    required this.xpGained,
    required this.isLevelUp,
    required this.newLevel,
    this.onComplete,
  });

  final int xpGained;
  final bool isLevelUp;
  final int newLevel;
  final VoidCallback? onComplete;

  @override
  State<XpPopupWidget> createState() => _XpPopupWidgetState();
}

class _XpPopupWidgetState extends State<XpPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isLevelUp
                      ? const Color(0xFFFFD600).withValues(alpha: 0.95)
                      : const Color(0xFF00E676).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isLevelUp
                          ? const Color(0xFFFFD600).withValues(alpha: 0.5)
                          : const Color(0xFF00E676).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLevelUp) ...[
                      Image.asset(
                        'assets/icons/training/star.png',
                        height: 32,
                        width: 32,
                        color: Colors.black,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LEVEL UP!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Level ${widget.newLevel}',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: widget.isLevelUp ? Colors.black : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.xpGained} XP',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: widget.isLevelUp
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows an XP popup overlay on the screen
void showXpPopup(
  BuildContext context, {
  required int xpGained,
  required bool isLevelUp,
  required int newLevel,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: 0,
      right: 0,
      child: Center(
        child: XpPopupWidget(
          xpGained: xpGained,
          isLevelUp: isLevelUp,
          newLevel: newLevel,
          onComplete: () {
            entry.remove();
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
}
