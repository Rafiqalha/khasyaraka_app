import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/core/services/quiz_haptic_service.dart';

/// Duolingo-style option button with 3D cartoon effects
///
/// Features:
/// - 3D depth effect with thick bottom border
/// - Press down animation (border shrinks)
/// - Shake animation for wrong answers
/// - Inline feedback with icons (check/X)
/// - Haptic feedback integration
class DuolingoOptionButton extends StatefulWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isChecked;
  final bool isCorrectAnswer;
  final VoidCallback? onTap;

  /// Optional: highlight correct answer when user answers wrong
  final bool showCorrectHighlight;

  const DuolingoOptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isChecked,
    required this.isCorrectAnswer,
    required this.onTap,
    this.showCorrectHighlight = false,
  });

  @override
  State<DuolingoOptionButton> createState() => _DuolingoOptionButtonState();
}

// ✅ Fixed: Used TickerProviderStateMixin for multiple controllers
class _DuolingoOptionButtonState extends State<DuolingoOptionButton>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _bounceController; // ✅ NEW: Bounce animation
  late Animation<double> _bounceAnimation;

  bool _isPressed = false;
  bool _hasTriggeredFeedback = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Shake animation: rapid left-right oscillation
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // ✅ NEW: Bounce animation for correct answer
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Bounce: Scale up slightly then back to normal with elastic effect
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(DuolingoOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shake/bounce and haptic when answer is checked and this is the relevant selection
    if (widget.isChecked && !oldWidget.isChecked && !_hasTriggeredFeedback) {
      _hasTriggeredFeedback = true;

      if (widget.isSelected && !widget.isCorrectAnswer) {
        // Wrong answer: shake + heavy haptic
        _shakeController.forward(from: 0);
        QuizHapticService.wrongFeedback();
      } else if (widget.isSelected && widget.isCorrectAnswer) {
        // ✅ Correct answer: Bounce + LONG vibration
        _bounceController
            .forward(from: 0)
            .then((_) => _bounceController.reverse());
        QuizHapticService.correctFeedback();
      } else if (widget.showCorrectHighlight && widget.isCorrectAnswer) {
        // Highlight correct answer (when user was wrong): Just bounce slightly
        _bounceController
            .forward(from: 0)
            .then((_) => _bounceController.reverse());
      }
    }

    // Reset feedback flag when moving to next question
    if (!widget.isChecked && oldWidget.isChecked) {
      _hasTriggeredFeedback = false;
      _bounceController.reset();
      _shakeController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose(); // ✅ NEW
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _bounceAnimation]),
      builder: (context, child) {
        // Calculate shake offset (sin wave for smooth oscillation)
        final shakeOffset = sin(_shakeAnimation.value * pi * 6) * 8;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: _bounceAnimation.value, // ✅ Apply bounce scale
            child: child,
          ),
        );
      },
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    // --- DETERMINE COLORS & STATE ---
    Color bgColor;
    Color borderColor;
    Color shadowColor;
    Color textColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (widget.isChecked) {
      if (widget.isSelected && widget.isCorrectAnswer) {
        // ✅ Correct answer that was selected
        bgColor = AppColors.duoSuccessLight;
        borderColor = AppColors.duoSuccess;
        shadowColor = AppColors.duoSuccessShadow;
        textColor = AppColors.duoSuccess;
        trailingIcon = Icons.check_circle;
        iconColor = AppColors.duoSuccess;
      } else if (widget.isSelected && !widget.isCorrectAnswer) {
        // ❌ Wrong answer that was selected
        bgColor = AppColors.duoErrorLight;
        borderColor = AppColors.duoError;
        shadowColor = AppColors.duoErrorShadow;
        textColor = AppColors.duoError;
        trailingIcon = Icons.cancel;
        iconColor = AppColors.duoError;
      } else if (widget.showCorrectHighlight && widget.isCorrectAnswer) {
        // 💡 Highlight the correct answer (when user got it wrong)
        bgColor = AppColors.duoSuccessLight.withOpacity(0.5);
        borderColor = AppColors.duoSuccess.withOpacity(0.6);
        shadowColor = AppColors.duoSuccessShadow.withOpacity(0.4);
        textColor = AppColors.duoSuccess;
        trailingIcon = Icons.check_circle_outline;
        iconColor = AppColors.duoSuccess.withOpacity(0.7);
      } else {
        // Other options after check
        bgColor = Colors.white;
        borderColor = AppColors.duoNeutralBorder;
        shadowColor = AppColors.duoButtonShadow;
        textColor = AppColors.textDark.withOpacity(0.5);
        trailingIcon = null;
      }
    } else if (widget.isSelected) {
      // 🔵 Selected but not checked yet
      bgColor = AppColors.duoSelectedBg;
      borderColor = AppColors.duoSelectedBorder;
      shadowColor = AppColors.duoSelectedBorder;
      textColor = AppColors.textDark;
      trailingIcon = null;
    } else {
      // ⚪ Normal state
      bgColor = Colors.white;
      borderColor = AppColors.duoNeutralBorder;
      shadowColor = AppColors.duoButtonShadow;
      textColor = AppColors.textDark;
      trailingIcon = null;
    }

    // 3D depth effect: thicker bottom border
    final bottomBorderWidth = _isPressed ? 2.0 : 4.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: widget.isChecked
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isChecked
            ? null
            : (_) => setState(() => _isPressed = false),
        onTapCancel: widget.isChecked
            ? null
            : () => setState(() => _isPressed = false),
        onTap: widget.isChecked
            ? null
            : () {
                QuizHapticService.selectionFeedback();
                widget.onTap?.call();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              // 3D bottom shadow
              BoxShadow(
                color: shadowColor,
                offset: Offset(0, bottomBorderWidth),
                blurRadius: 0,
              ),
            ],
          ),
          // Offset to simulate press down
          transform: _isPressed
              ? Matrix4.translationValues(0, 2, 0)
              : Matrix4.identity(),
          child: Row(
            children: [
              // Letter index (A, B, C, D)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      widget.isChecked &&
                          (widget.isSelected ||
                              (widget.showCorrectHighlight &&
                                  widget.isCorrectAnswer))
                      ? borderColor.withOpacity(0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + widget.index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Answer text
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),

              // Trailing icon (check/X)
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: iconColor, size: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
