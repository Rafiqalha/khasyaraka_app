import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class InputTextWidget extends StatefulWidget {
  final String? initialValue;
  final Function(String) onAnswerChanged;
  final bool isChecked;
  final bool isCorrect;
  final String? correctAnswer;

  const InputTextWidget({
    super.key,
    this.initialValue,
    required this.onAnswerChanged,
    required this.isChecked,
    required this.isCorrect,
    this.correctAnswer,
  });

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  // ✅ Updated for Red/Green Feedback & Correct Answer Card (Fixed White Background Bug)
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InputTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.duoNeutralBorder;
    Color bgColor = Colors.white;
    Color textColor = AppColors.textDark;

    if (widget.isChecked) {
      if (widget.isCorrect) {
        borderColor = AppColors.duoSuccess;
        bgColor = AppColors.duoSuccessLight;
        textColor = AppColors.duoSuccess;
      } else {
        borderColor = AppColors.duoError;
        bgColor = AppColors.duoErrorLight;
        textColor = AppColors.duoError;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(widget.isChecked ? 0.5 : 0.2),
                blurRadius: 0,
                offset: const Offset(0, 4), // 3D effect
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widget.isChecked,
            onChanged: (value) {
              widget.onAnswerChanged(value);
            },
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              filled: true, // Allow fill color overrides
              fillColor:
                  Colors.transparent, // Transparent to show container color
              hintText: "Ketik jawabanmu di sini...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              enabledBorder: InputBorder.none, // Ensure no borders from theme
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: widget.isChecked
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        widget.isCorrect ? Icons.check_circle : Icons.cancel,
                        color: widget.isCorrect
                            ? AppColors.duoSuccess
                            : AppColors.duoError,
                        size: 28,
                      ),
                    )
                  : null,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),

        // Correct Answer Card (Only if checked and WRONG)
        if (widget.isChecked &&
            !widget.isCorrect &&
            widget.correctAnswer != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.duoSuccessLight.withOpacity(
                0.5,
              ), // Lighter green for info
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.duoSuccess.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_circle,
                      color: AppColors.duoSuccess,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Jawaban yang benar:", // Correct Answer Title
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.duoSuccess,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.correctAnswer!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
