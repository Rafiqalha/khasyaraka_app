import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import '../../logic/lesson_controller.dart';
import '../widgets/lesson_progress_header.dart';
import '../widgets/option_button.dart';
import '../widgets/arrange_words_widget.dart';
import '../widgets/listening_widget.dart';
import '../widgets/input_text_widget.dart';
import '../widgets/sorting_widget.dart';
import '../widgets/matching_widget.dart';
import '../widgets/feedback_card_widget.dart';
import 'lesson_result_page.dart';

class QuizPage extends StatefulWidget {
  final String? levelId; // Optional: for level-based quiz
  final String? unitId; // Optional: for unit-based quiz (all questions from all levels)
  
  /// Create QuizPage with levelId (single level questions)
  const QuizPage.withLevel({super.key, required this.levelId}) : unitId = null;
  
  /// Create QuizPage with unitId (all questions from all levels in unit)
  const QuizPage.withUnit({super.key, required this.unitId}) : levelId = null;
  
  // Legacy constructor for backward compatibility
  const QuizPage({super.key, this.levelId}) : unitId = null;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late LessonController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LessonController();
    
    // Load questions based on what's provided
    if (widget.unitId != null) {
      // Load all questions from unit (all levels combined)
      _controller.loadQuestionsByUnit(widget.unitId!);
    } else if (widget.levelId != null) {
      // Load questions for single level
      _controller.loadQuestions(widget.levelId!);
    } else {
      // Error: neither provided
      _controller.errorMessage = "Level ID atau Unit ID harus disediakan.";
      _controller.isLoading = false;
    }
    
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_controller.isCompleted && mounted) {
      // Use WidgetsBinding to ensure navigation happens after frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        try {
          // CRITICAL: Call finishLesson to calculate XP reward BEFORE navigating
          // This ensures we have the correct XP earned (0 if already completed)
          int xpEarned = 0;
          try {
            xpEarned = await _controller.finishLesson(isSuccess: true);
            debugPrint('💰 [QUIZ] XP Earned from finishLesson: $xpEarned');
          } catch (e) {
            debugPrint('⚠️ [QUIZ] Error calling finishLesson: $e');
            // Continue with 0 XP if finishLesson fails
          }
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LessonResultPage(
                score: _controller.score,
                totalQuestions: _controller.questions.length,
                xpEarned: xpEarned, // Use XP from finishLesson, not userXp
                streak: _controller.userStreak,
                lessonController: _controller,
              ),
            ),
          );
        } catch (e) {
          debugPrint('❌ [QUIZ] Error navigating to result page: $e');
          // Fallback: try to pop back to training map
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<LessonController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Scaffold(
              backgroundColor: AppColors.scoutBg,
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.forestGreen),
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              backgroundColor: AppColors.scoutBg,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Error'),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: AppColors.alertRed,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.scoutBrown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.scoutBrown.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                        if (widget.unitId != null) {
                          controller.loadQuestionsByUnit(widget.unitId!);
                        } else if (widget.levelId != null) {
                          controller.loadQuestions(widget.levelId!);
                        }
                      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // CRITICAL: Handle case when questions are empty after loading
          if (!controller.isLoading && controller.questions.isEmpty) {
            return Scaffold(
              backgroundColor: AppColors.scoutBg,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Tidak Ada Soal'),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 80,
                        color: AppColors.scoutBrown.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Level Belum Tersedia',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.scoutBrown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.levelId != null
                            ? 'Level "${widget.levelId}" belum memiliki soal. Silakan coba level lain.'
                            : 'Unit ini belum memiliki soal. Silakan coba unit lain.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.scoutBrown.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (controller.currentQuestion == null) {
            return Scaffold(
              backgroundColor: AppColors.scoutBg,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Error'),
              ),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.red),
                      SizedBox(height: 24),
                      Text(
                        'Tidak ada pertanyaan',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.scoutBg,
            appBar: LessonProgressHeader(
              current: controller.currentQuestionIndex,
              total: controller.questions.length,
              onExit: () => _showExitDialog(context, controller),
            ),
            body: Column(
              children: [
                _buildHeartsBar(controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuestionCard(controller),
                        const SizedBox(height: 24),
                        _buildAnswerSection(controller),
                        if (controller.showFeedback)
                          _buildFeedbackSection(controller),
                      ],
                    ),
                  ),
                ),
                if (!controller.showFeedback) _buildCheckButton(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeartsBar(LessonController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.hasdukWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              controller.maxHearts,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  index < controller.userHearts
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: AppColors.alertRed,
                  size: 24,
                ),
              ),
            ),
          ),
          Row(
            children: [
              if (controller.userXp > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldBadge.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: AppColors.goldBadge, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '+${controller.userXp} XP',
                        style: const TextStyle(
                          color: AppColors.goldBadge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (controller.userStreak > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.actionOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.actionOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.userStreak}',
                        style: const TextStyle(
                          color: AppColors.actionOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(LessonController controller) {
    final question = controller.currentQuestion!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.hasdukWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listening type: audio URL is in payload
          if (question.type == 'listening')
            Builder(
              builder: (context) {
                final audioUrl = question.payload['audio_url'] as String?;
                if (audioUrl != null && audioUrl.isNotEmpty) {
                  return ListeningWidget(audioUrl: audioUrl);
                }
                return const SizedBox.shrink();
              },
            ),
          // Question text (always show)
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.scoutBrown,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(LessonController controller) {
    final question = controller.currentQuestion!;

    switch (question.type) {
      case 'multiple_choice': {
        final options = question.getMultipleChoiceOptions() ?? [];
        return Column(
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            // Check if this is correct answer (from payload)
            final correctAnswer = question.payload['correct_answer'] as String?;
            final isCorrect = correctAnswer != null && option == correctAnswer;
            
            return OptionButton(
              text: option,
              index: index,
              isSelected: controller.selectedOptionIndex == index,
              isChecked: controller.isChecked,
              isCorrectAnswer: isCorrect,
              onTap: () => controller.selectOption(index),
            );
          }).toList(),
        );
      }

      case 'sorting':
      case 'ordering': {
        final items = question.getOrderingItems() ?? 
                     (question.payload['items'] as List<dynamic>?)
                         ?.map((e) => e.toString())
                         .toList() ?? [];
        return SortingWidget(
          items: items,
          isChecked: controller.isChecked,
          isCorrect: controller.isCorrect,
          onOrderChanged: (order) => controller.updateSortingOrder(order),
        );
      }

      case 'word_bank':
      case 'arrange_words': {
        // Get words from payload
        final words = (question.payload['words'] as List<dynamic>?)
                         ?.map((e) => e.toString())
                         .toList() ??
                     (question.payload['items'] as List<dynamic>?)
                         ?.map((e) => e.toString())
                         .toList() ?? [];
        return ArrangeWordsWidget(
          words: words,
          onAnswerChanged: (answer) => controller.updateStringAnswer(answer),
        );
      }

      case 'fill_blank':
      case 'input':
      case 'text_input': {
        // Get correct answer from payload (for display after check)
        final correctAnswer = question.payload['correct_answer'] as String?;
        return InputTextWidget(
          initialValue: controller.userAnswerString,
          onAnswerChanged: (answer) => controller.updateStringAnswer(answer),
          isChecked: controller.isChecked,
          isCorrect: controller.isCorrect,
          correctAnswer: correctAnswer,
        );
      }

      case 'matching': {
        final matchingData = question.getMatchingItems();
        if (matchingData == null) {
          return const Text('Data matching tidak valid');
        }
        
        // Convert to pairs format expected by MatchingWidget
        final pairs = <Map<String, String>>[];
        final leftItems = matchingData['left'] ?? [];
        final rightItems = matchingData['right'] ?? [];
        
        for (int i = 0; i < leftItems.length && i < rightItems.length; i++) {
          pairs.add({
            'left': leftItems[i],
            'right': rightItems[i],
          });
        }
        
        return MatchingWidget(
          pairs: pairs,
          isChecked: controller.isChecked,
          isCorrect: controller.isCorrect,
          onAnswerChanged: (pairs) => controller.updateMatchingAnswer(pairs),
        );
      }

      case 'listening': {
        // Listening: options are in payload (skip first if it's audio URL)
        final options = (question.payload['options'] as List<dynamic>?)
                           ?.map((e) => e.toString())
                           .toList() ?? [];
        final correctAnswer = question.payload['correct_answer'] as String?;
        
        return Column(
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isCorrect = correctAnswer != null && option == correctAnswer;
            
            return OptionButton(
              text: option,
              index: index,
              isSelected: controller.selectedOptionIndex == index,
              isChecked: controller.isChecked,
              isCorrectAnswer: isCorrect,
              onTap: () => controller.selectOption(index),
            );
          }).toList(),
        );
      }

      case 'true_false': {
        final options = ['Benar', 'Salah'];
        final correctAnswer = question.payload['correct_answer'] as bool?;
        
        return Column(
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            // Map boolean to text
            final isCorrect = (correctAnswer == true && option == 'Benar') ||
                            (correctAnswer == false && option == 'Salah');
            
            return OptionButton(
              text: option,
              index: index,
              isSelected: controller.selectedOptionIndex == index,
              isChecked: controller.isChecked,
              isCorrectAnswer: isCorrect,
              onTap: () => controller.selectOption(index),
            );
          }).toList(),
        );
      }

      default:
        return Text('Tipe pertanyaan tidak didukung: ${question.type}');
    }
  }

  Widget _buildFeedbackSection(LessonController controller) {
    // Explanation is not in frontend model (backend only for security)
    // Can be added to payload if needed in future
    final explanation = controller.currentQuestion?.payload['explanation'] as String?;
    
    return FeedbackCardWidget(
      isCorrect: controller.isCorrect,
      explanation: explanation,
      onContinue: () => controller.nextQuestion(),
    );
  }

  Widget _buildCheckButton(LessonController controller) {
    final hasAnswer = controller.selectedOptionIndex != null ||
        (controller.userAnswerString != null &&
            controller.userAnswerString!.isNotEmpty) ||
        (controller.userSortingOrder != null &&
            controller.userSortingOrder!.isNotEmpty) ||
        (controller.userMatchingPairs != null &&
            controller.userMatchingPairs!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.hasdukWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasAnswer && controller.canAnswer && controller.hasHearts
              ? () => controller.checkAnswer()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Text(
            "Periksa",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context, LessonController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Latihan?'),
        content: const Text('Progress kamu akan hilang jika keluar sekarang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.exitLesson();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
