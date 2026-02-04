import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/training_controller.dart';
import '../../logic/lesson_controller.dart';

class LessonResultPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int xpEarned; // XP earned from finishLesson (0 if already completed)
  final int streak;
  final LessonController lessonController;

  const LessonResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.streak,
    required this.lessonController,
  });

  @override
  State<LessonResultPage> createState() => _LessonResultPageState();
}

class _LessonResultPageState extends State<LessonResultPage> {
  bool _isProcessing = false; // Prevent double tap

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
              ),
              const SizedBox(height: 32),
              const Text(
                "Latihan Selesai!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF58CC02),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Kamu menjawab benar ${widget.score} dari ${widget.totalQuestions} soal.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                decoration: BoxDecoration(
                  color: widget.xpEarned > 0 
                      ? Colors.grey.shade100 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.xpEarned > 0 
                        ? Colors.grey.shade300 
                        : Colors.grey.shade400,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: widget.xpEarned > 0 
                          ? Colors.amber 
                          : Colors.grey.shade600,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "+${widget.xpEarned} XP",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.xpEarned > 0 
                                ? Colors.brown.shade800 
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (widget.xpEarned == 0)
                          Text(
                            "Sudah Selesai",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _handleContinue,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("LANJUTKAN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_isProcessing) return; // Prevent double tap
    
    setState(() {
      _isProcessing = true;
    });

    debugPrint('🔄 [RESULT] Button pressed, starting finish flow...');

    try {
      final trainingController =
          Provider.of<TrainingController>(context, listen: false);

      debugPrint('🔄 [RESULT] Button pressed, starting finish flow...');

      // NOTE: finishLesson was already called in QuizPage to get XP earned
      // We don't need to call it again here to avoid duplicate processing
      debugPrint('✅ [RESULT] finishLesson already completed in QuizPage (XP: ${widget.xpEarned})');

      debugPrint('✅ [RESULT] finishLesson completed');

      // CRITICAL: Add longer delay to ensure SharedPreferences is fully written
      // This ensures updateUserStats() has time to save to disk before we read it
      await Future.delayed(Duration(milliseconds: 300));

      debugPrint('🔄 [RESULT] Calling loadProgress...');

      // Refresh progress to show unlocked levels
      try {
        await trainingController.loadProgress();
        debugPrint('✅ [RESULT] Progress refreshed successfully');
        
        // CRITICAL: loadProgress() already calls loadUserStats() internally
        // But we can also explicitly call it to ensure stats are refreshed
        // Add small delay to ensure SharedPreferences read is fresh
        await Future.delayed(Duration(milliseconds: 100));
        await trainingController.loadUserStats();
        debugPrint('✅ [RESULT] User stats refreshed: XP=${trainingController.userXp}, Streak=${trainingController.userStreak}');
        
        // CRITICAL: Add another small delay to ensure UI rebuild completes
        await Future.delayed(Duration(milliseconds: 150));
      } catch (e, stackTrace) {
        debugPrint('⚠️ [RESULT] Error loading progress: $e');
        debugPrint('   Stack trace: $stackTrace');
        // Continue navigation even if loadProgress fails
      }

      debugPrint('✅ [RESULT] Navigating back to training map...');

      // CRITICAL: Use addPostFrameCallback to ensure navigation happens when widget is still mounted
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            debugPrint('⚠️ [RESULT] Cannot navigate - context not available');
          }
        });
      } else {
        debugPrint('⚠️ [RESULT] Widget not mounted, cannot navigate');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [RESULT] Unexpected error: $e');
      debugPrint('   Stack trace: $stackTrace');

      // CRITICAL: Even if there's an error, try to navigate back to prevent black screen
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }
    } finally {
      // Don't reset _isProcessing here - let navigation happen first
      // It will be reset when widget is disposed
    }
  }
}