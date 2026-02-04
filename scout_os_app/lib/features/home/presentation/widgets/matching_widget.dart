import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class MatchingWidget extends StatefulWidget {
  final List<Map<String, String>> pairs;
  final bool isChecked;
  final bool isCorrect;
  final Function(Map<String, String>) onAnswerChanged;

  const MatchingWidget({
    super.key,
    required this.pairs,
    required this.isChecked,
    required this.isCorrect,
    required this.onAnswerChanged,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  final Map<String, String> _answers = {};

  List<String> get _rightOptions {
    // CRITICAL FIX: Remove duplicates and empty strings to prevent dropdown crashes
    final options = widget.pairs
        .map((pair) => pair['right'] ?? '')
        .where((option) => option.isNotEmpty) // Remove empty strings
        .toSet() // Remove duplicates
        .toList();
    return options;
  }

  void _updateAnswer(String left, String right) {
    setState(() {
      _answers[left] = right;
    });
    widget.onAnswerChanged(Map<String, String>.from(_answers));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.pairs.map((pair) {
        final left = pair['left'] ?? '';
        final correctRight = pair['right'] ?? '';
        final selectedRight = _answers[left];

        Color borderColor = Colors.grey.shade300;
        if (widget.isChecked) {
          if (selectedRight == correctRight) {
            borderColor = AppColors.forestGreen;
          } else {
            borderColor = AppColors.alertRed;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.scoutWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  left,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRight,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _rightOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: widget.isChecked
                      ? null
                      : (value) {
                          if (value != null) {
                            _updateAnswer(left, value);
                          }
                        },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
