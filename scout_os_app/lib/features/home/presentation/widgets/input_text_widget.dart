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
    Color borderColor = Colors.grey.shade300;
    Color bgColor = AppColors.hasdukWhite;

    if (widget.isChecked) {
      if (widget.isCorrect) {
        borderColor = AppColors.forestGreen;
        bgColor = AppColors.forestGreen.withValues(alpha: 0.1);
      } else {
        borderColor = AppColors.alertRed;
        bgColor = AppColors.alertRed.withValues(alpha: 0.1);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: widget.isChecked ? 3 : 2,
        ),
        boxShadow: widget.isChecked
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
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
          color: widget.isChecked
              ? (widget.isCorrect ? AppColors.forestGreen : AppColors.alertRed)
              : AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: "Ketik jawabanmu di sini...",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          suffixIcon: widget.isChecked
              ? Icon(
                  widget.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: widget.isCorrect
                      ? AppColors.forestGreen
                      : AppColors.alertRed,
                )
              : null,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
