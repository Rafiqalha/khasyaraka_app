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
  // ✅ Fix: Matching widget shuffle & overflow handled

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  final Map<String, String> _answers = {};
  late List<String> _shuffledRightOptions;

  @override
  void initState() {
    super.initState();
    _initializeOptions();
  }

  @override
  void didUpdateWidget(MatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reset if the actual CONTENT changed (new question), not just a new list reference
    if (!_pairsContentEqual(widget.pairs, oldWidget.pairs)) {
      _answers.clear();
      _initializeOptions();
    }
  }

  bool _pairsContentEqual(
    List<Map<String, String>> a,
    List<Map<String, String>> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i]['left'] != b[i]['left'] || a[i]['right'] != b[i]['right'])
        return false;
    }
    return true;
  }

  void _initializeOptions() {
    // Get all right-side options, remove duplicates/empty, and shuffle.
    _shuffledRightOptions = widget.pairs
        .map((pair) => pair['right'] ?? '')
        .where((option) => option.isNotEmpty)
        .toSet()
        .toList();
    _shuffledRightOptions.shuffle();
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
        Color bgColor = AppColors.scoutWhite;

        if (widget.isChecked) {
          if (selectedRight == correctRight) {
            borderColor = AppColors.forestGreen;
            bgColor = AppColors.duoSuccessLight.withOpacity(0.3);
          } else {
            borderColor = AppColors.alertRed;
            bgColor = AppColors.duoErrorLight.withOpacity(0.3);
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align center vertically
            children: [
              Expanded(
                flex: 2, // Give left side reasonable space
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
                flex: 3, // Give dropdown slightly more space
                child: DropdownButtonFormField<String>(
                  value: selectedRight,
                  isExpanded: true, // ✅ Fix for overflow
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _shuffledRightOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            overflow:
                                TextOverflow.ellipsis, // ✅ Fix for long text
                            maxLines: 2,
                            style: const TextStyle(fontSize: 14),
                          ),
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
