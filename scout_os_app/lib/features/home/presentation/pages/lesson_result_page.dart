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

    debugPrint('🔄 [RESULT] Button pressed - INSTANT navigation flow...');

    try {
      final trainingController =
          Provider.of<TrainingController>(context, listen: false);

      // ✅ OPTIMISTIC UI: Navigate FIRST, then refresh in background
      // This makes the button feel instant/snappy
      
      // ✅ OPTIMISTIC UI: Update local state INSTANTLY before navigation
      // This ensures the map shows the new progress immediately
      final currentLevelId = widget.lessonController.currentLevelId;
      if (currentLevelId != null) {
        trainingController.unlockNextLevelLocally(currentLevelId);
      }

      // Navigate back immediately
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('✅ [RESULT] Navigation completed instantly!');
      }
      
      // 🔄 BACKGROUND: Refresh data after navigation (non-blocking)
      // Use Future.microtask to ensure this runs after navigation completes
      Future.microtask(() async {
        try {
          debugPrint('🔄 [RESULT] Background: Refreshing training data...');
          
          // ✅ CRITICAL: Refresh ALL training data including level status
          // This ensures UI shows updated COMPLETED/UNLOCKED status
          await Future.wait([
            trainingController.loadPathData(),    // ← FIXED: Correct method name
            trainingController.loadProgress(),
            trainingController.loadUserStats(),
          ]);
          
          debugPrint('✅ [RESULT] Background refresh complete: XP=${trainingController.userXp}, Hearts=${trainingController.userHearts}');
        } catch (e) {
          debugPrint('⚠️ [RESULT] Background refresh failed (non-critical): $e');
        }
      });
      
    } catch (e, stackTrace) {
      debugPrint('❌ [RESULT] Unexpected error: $e');
      debugPrint('   Stack trace: $stackTrace');

      // Fallback: try to navigate back
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}