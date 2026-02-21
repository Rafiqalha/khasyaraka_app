import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/training_controller.dart';
import '../../logic/lesson_controller.dart';

class LessonResultPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final int streak;
  final int timeSeconds;
  final LessonController lessonController;

  const LessonResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.streak,
    required this.timeSeconds,
    required this.lessonController,
  });

  @override
  State<LessonResultPage> createState() => _LessonResultPageState();
}

class _LessonResultPageState extends State<LessonResultPage>
    with TickerProviderStateMixin {
  bool _isProcessing = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _counterController;
  late Animation<double> _fadeAnim;
  late Animation<double> _counterAnim;

  // Computed values
  int get _accuracyPercent => widget.totalQuestions > 0
      ? ((widget.score / widget.totalQuestions) * 100).round()
      : 0;

  String get _timeFormatted {
    final m = widget.timeSeconds ~/ 60;
    final s = widget.timeSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _titleMessage {
    if (_accuracyPercent == 100) return 'Nilai sempurna!';
    if (_accuracyPercent >= 80) return 'Luar biasa!';
    if (_accuracyPercent >= 60) return 'Bagus sekali!';
    if (_accuracyPercent >= 40) return 'Terus berlatih!';
    return 'Jangan menyerah!';
  }

  String get _subtitleMessage {
    if (_accuracyPercent == 100) return 'Beri hormat!';
    if (_accuracyPercent >= 80) return 'Kamu hebat!';
    if (_accuracyPercent >= 60) return 'Hampir sempurna!';
    if (_accuracyPercent >= 40) return 'Ayo tingkatkan lagi!';
    return 'Coba lagi ya!';
  }

  String get _accuracyLabel {
    if (_accuracyPercent == 100) return 'LUAR BIASA';
    if (_accuracyPercent >= 80) return 'HEBAT';
    if (_accuracyPercent >= 60) return 'BAGUS';
    return 'COBA LAGI';
  }

  String get _speedLabel {
    if (widget.timeSeconds < 60) return 'KILAT';
    if (widget.timeSeconds < 180) return 'PESAT';
    return 'SANTAI';
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _counterAnim = CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutCubic,
    );

    // Start animations immediately
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _counterController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131F24),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Trophy icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 80,
                    color: _accuracyPercent >= 60
                        ? Colors.amber
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  _titleMessage,
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _subtitleMessage,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),

                const Spacer(flex: 2),

                // Stat cards row
                AnimatedBuilder(
                  animation: _counterAnim,
                  builder: (context, _) {
                    return Row(
                      children: [
                        // XP Card
                        Expanded(
                          child: _StatCard(
                            label: 'TOTAL XP',
                            value:
                                '${(_counterAnim.value * widget.xpEarned).round()}',
                            icon: Icons.bolt_rounded,
                            bgColor: const Color(0xFFFFC800),
                            borderColor: const Color(0xFFE5A800),
                            iconColor: const Color(0xFFFFC800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Accuracy Card
                        Expanded(
                          child: _StatCard(
                            label: _accuracyLabel,
                            value:
                                '${(_counterAnim.value * _accuracyPercent).round()}%',
                            icon: Icons.check_circle_rounded,
                            bgColor: const Color(0xFF58CC02),
                            borderColor: const Color(0xFF46A302),
                            iconColor: const Color(0xFF58CC02),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time Card
                        Expanded(
                          child: _StatCard(
                            label: _speedLabel,
                            value: _timeFormatted,
                            icon: Icons.timer_rounded,
                            bgColor: const Color(0xFF1CB0F6),
                            borderColor: const Color(0xFF0E8DC7),
                            iconColor: const Color(0xFF1CB0F6),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(flex: 3),

                // KLAIM XP button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB0F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isProcessing ? null : _handleContinue,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'KLAIM XP',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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

    debugPrint('🔄 [RESULT] Button pressed - navigation flow...');

    try {
      final trainingController = Provider.of<TrainingController>(
        context,
        listen: false,
      );

      // ✅ OPTIMISTIC UI: Use BACKEND-provided data for precise local updates
      final currentLevelId = widget.lessonController.currentLevelId;
      final backendStatus = widget.lessonController.lastCompletedStatus;
      final nextLevelId = widget.lessonController.lastNextLevelId;

      debugPrint(
        '🔄 [RESULT] Backend data: currentLevel=$currentLevelId, status=$backendStatus, nextLevel=$nextLevelId',
      );

      if (currentLevelId != null && backendStatus != null) {
        // ✅ Use backend-confirmed status (COMPLETED/UNLOCKED) for optimistic update
        trainingController.applyBackendResult(
          completedLevelId: currentLevelId,
          completedStatus: backendStatus,
          nextLevelId: nextLevelId,
        );
      } else if (currentLevelId != null) {
        // Fallback: if backend didn't respond, use local guess
        trainingController.unlockNextLevelLocally(currentLevelId);
      }

      // ✅ CRITICAL: Update XP + streak directly from submit_progress response
      // The profile API has a stale memory cache, so use the fresh values from finishLesson
      if (widget.xpEarned > 0) {
        trainingController.userXp = widget.lessonController.userXp;
        trainingController.userStreak = widget.lessonController.userStreak;
        debugPrint(
          '💰 [RESULT] Updated XP=${trainingController.userXp}, Streak=${trainingController.userStreak} from submit_progress response',
        );
      }

      // Navigate back immediately
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('✅ [RESULT] Navigation completed!');
      }

      // 🔄 BACKGROUND: Only refresh progress + stats (NOT loadPathData which rebuilds units
      // from cache and would briefly overwrite the optimistic COMPLETED status)
      Future.microtask(() async {
        try {
          await Future.delayed(const Duration(seconds: 1));
          debugPrint('🔄 [RESULT] Background: Refreshing progress + stats...');
          await Future.wait([
            trainingController.loadProgress(),
            trainingController.loadUserStats(forceRefresh: true),
          ]);
          debugPrint(
            '✅ [RESULT] Background refresh complete: XP=${trainingController.userXp}',
          );
        } catch (e) {
          debugPrint(
            '⚠️ [RESULT] Background refresh failed (non-critical): $e',
          );
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

/// Duolingo-style stat card with icon, label, and value
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label
        Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        // Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2F38),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
