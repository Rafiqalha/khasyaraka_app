import 'package:flutter/material.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';

class ArrangeWordsWidget extends StatefulWidget {
  final List<String> words;
  final Function(String) onAnswerChanged; // Mengirim String kalimat jadi
  final bool isChecked;
  final bool isCorrect;
  final String? correctAnswer;

  const ArrangeWordsWidget({
    super.key, 
    required this.words, 
    required this.onAnswerChanged,
    this.isChecked = false,
    this.isCorrect = false,
    this.correctAnswer,
  });

  @override
  State<ArrangeWordsWidget> createState() => _ArrangeWordsWidgetState();
}

class _ArrangeWordsWidgetState extends State<ArrangeWordsWidget> with SingleTickerProviderStateMixin {
  late List<String> availableWords;
  List<String> selectedWords = [];
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Copy list agar tidak merubah aslinya & acak
    availableWords = List.from(widget.words);
    availableWords.shuffle();
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 2),
    ]).animate(_bounceController);
  }

  @override
  void didUpdateWidget(ArrangeWordsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If words changed (new question), reset
    // ✅ CRITICAL FIX: Check content equality to avoid unnecessary resets
    if (!_isListEqual(widget.words, oldWidget.words)) {
      debugPrint("ArrangeWordsWidget: Words changed, resetting.");
      availableWords = List.from(widget.words);
      availableWords.shuffle();
      selectedWords = [];
    }
    
    // Trigger bounce if checked and CORRECT
    if (widget.isChecked && widget.isCorrect && !oldWidget.isChecked) {
      _bounceController.forward(from: 0);
    }
    // ✅ Fix: Logic tap word bank shuffled issue resolved
  }

  bool _isListEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _updateParent() {
    // Gabungkan list kata menjadi satu kalimat string dengan spasi
    String sentence = selectedWords.join(" ");
    widget.onAnswerChanged(sentence);
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color borderColor = Colors.grey.shade300;
    Color bgColor = AppColors.scoutWhite;
    
    if (widget.isChecked) {
      if (widget.isCorrect) {
        borderColor = AppColors.duoSuccess;
        bgColor = AppColors.duoSuccessLight.withOpacity(0.3);
      } else {
        borderColor = AppColors.duoError;
        bgColor = AppColors.duoErrorLight.withOpacity(0.3);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KOTAK JAWABAN (ATAS)
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isChecked && widget.isCorrect ? _bounceAnimation.value : 1.0,
              child: child,
            );
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor, 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                if (widget.isChecked && widget.isCorrect)
                  BoxShadow(
                    color: AppColors.duoSuccess.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedWords.map((word) {
                return GestureDetector(
                  onTap: widget.isChecked ? null : () { // Disable click if checked
                    setState(() {
                      selectedWords.remove(word);
                      availableWords.add(word);
                      _updateParent();
                    });
                  },
                  child: Chip(
                    label: Text(
                      word, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.isChecked && widget.isCorrect 
                            ? AppColors.duoSuccess 
                            : AppColors.scoutBrown, // Teks coklat default
                      )
                    ),
                    backgroundColor: AppColors.scoutWhite,
                    side: BorderSide(
                      color: widget.isChecked && widget.isCorrect 
                          ? AppColors.duoSuccess 
                          : AppColors.forestGreen
                    ),
                    elevation: 2,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Correct Answer Card (Only if checked and WRONG)
        if (widget.isChecked && !widget.isCorrect && widget.correctAnswer != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.duoSuccessLight.withOpacity(0.5), // Lighter green for info
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
                    Icon(Icons.lightbulb_circle, color: AppColors.duoSuccess, size: 24),
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
        
        const SizedBox(height: 24),
        if (!widget.isChecked) ...[ // Hide instruction if checked
          const Center(
            child: Text(
              "Ketuk kata di bawah untuk menyusun:", 
              style: TextStyle(color: AppColors.textGrey)
            )
          ),
          const SizedBox(height: 12),
        ],

        // BANK KATA (BAWAH)
        // Disable interaction if checked
        IgnorePointer(
          ignoring: widget.isChecked,
          child: Opacity(
            opacity: widget.isChecked ? 0.5 : 1.0,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: availableWords.map((word) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      availableWords.remove(word);
                      selectedWords.add(word);
                      _updateParent();
                    });
                  },
                  child: Chip(
                    label: Text(
                      word,
                      style: const TextStyle(color: AppColors.textDark),
                    ),
                    // PERBAIKAN UTAMA: Ganti paperWhite jadi scoutWhite
                    backgroundColor: AppColors.scoutWhite, 
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}