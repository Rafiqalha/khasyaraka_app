import 'package:scout_os_app/core/widgets/terminal_loading.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/core/constants/app_colors.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import '../../logic/lesson_controller.dart';
import '../../logic/training_controller.dart';
import '../widgets/lesson_progress_header.dart';
import '../widgets/cipher_rotor_widget.dart';
import '../widgets/log_anomaly_widget.dart'; // ✅ NEW
import '../widgets/packet_sweeper_widget.dart'; // ✅ CYBER
import '../widgets/vuln_spotter_widget.dart'; // ✅ CYBER
import '../widgets/network_topology_cutter_widget.dart'; // ✅ CYBER
import 'lesson_result_page.dart';
import '../widgets/shake_animation.dart'; // ✅ NEW
import 'package:scout_os_app/core/services/quiz_haptic_service.dart'; // ✅ NEW
import '../widgets/quiz_feedback_sheet.dart'; // ✅ NEW

class QuizPage extends StatefulWidget {
  final String? levelId; // Optional: for level-based quiz
  final String?
  unitId; // Optional: for unit-based quiz (all questions from all levels)

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
  final GlobalKey<ShakeAnimationState> _shakeKey =
      GlobalKey<ShakeAnimationState>(); // ✅ NEW

  @override
  void initState() {
    super.initState();
    _controller = LessonController();

    // Initialize hearts from TrainingController (backend-synced)
    final trainingCtrl = context.read<TrainingController>();
    _controller.userHearts = trainingCtrl.userHearts;
    _controller.maxHearts = trainingCtrl.maxHearts;

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
          // Capture elapsed time before async call
          final timeSeconds = _controller.elapsedSeconds;

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

          if (!mounted) return; // Check mounted again after async await
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LessonResultPage(
                score: _controller.score,
                totalQuestions: _controller.questions.length,
                xpEarned: xpEarned,
                streak: _controller.userStreak,
                timeSeconds: timeSeconds,
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
              backgroundColor: AppColors.graphite,
              body: const Center(
                child: const TerminalLoading(fontSize: 24),
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              backgroundColor: AppColors.graphite,
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
                        controller.errorMessage!.contains('belum memiliki soal')
                            ? Icons.construction_rounded
                            : Icons.error_outline,
                        size: 80,
                        color: controller.errorMessage!.contains('belum memiliki soal')
                            ? AppColors.scoutBrown
                            : AppColors.alertRed,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.errorMessage!.contains('belum memiliki soal')
                            ? 'Materi Segera Hadir!'
                            : 'Oops! Terjadi Kesalahan',
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
              backgroundColor: AppColors.graphite,
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
              backgroundColor: AppColors.graphite,
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
            backgroundColor: AppColors.graphite,
            appBar: LessonProgressHeader(
              current: controller.currentQuestionIndex,
              total: controller.questions.length,
              userHearts: controller.userHearts,
              maxHearts: controller.maxHearts,
              onExit: () => _showExitDialog(context, controller),
            ),
            body: Stack(
              children: [
                // Matrix background canvas
                Positioned.fill(child: CustomPaint(painter: _MatrixBgPainter())),
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          100,
                        ), // Extra bottom padding for sheet
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildQuestionCard(controller),
                            const SizedBox(height: 24),
                            // Shake Animation for Answer Section
                            ShakeAnimation(
                              key: _shakeKey,
                              child: _buildAnswerSection(controller),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Check Button (Only visible when NOT showing feedback)
                    if (!controller.showFeedback) _buildCheckButton(controller),
                  ],
                ),

                // Feedback Sheet (Overlay)
                if (controller.showFeedback)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: QuizFeedbackSheet(
                      isCorrect: controller.isCorrect,
                      correctAnswer: _getCorrectAnswerText(controller),
                      onContinue: () => controller.nextQuestion(),
                      aiDialog: controller.aiDialog,
                      aiStatus: controller.aiStatus,
                      computationalScoreChange: controller.computationalScoreChange,
                      ethicalScoreChange: controller.ethicalScoreChange,
                      isAiEvaluating: controller.isAiEvaluating,
                      nextObjective: controller.nextObjective,
                      threatMutation: controller.threatMutation,
                      adaptiveNarrative: controller.adaptiveNarrative,
                      difficultyAdjustment: controller.difficultyAdjustment,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(LessonController controller) {
    final question = controller.currentQuestion!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text (always show)
          Text(
            question.question,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark mode
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
      case 'cipher_rotor':
        final encryptedText = question.payload['encrypted_text'] as String? ?? 'ERROR';
        return CipherRotorWidget(
          encryptedText: encryptedText,
          onChanged: (shift) {
            controller.selectOption(shift);
          },
        );

      case 'packet_sweeper':
        {
          final packets = (question.payload['packets'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];
          return PacketSweeperWidget(
            packets: packets,
            isChecked: controller.isChecked,
            isCorrect: controller.isCorrect,
            onSwipeComplete: (decisions) => controller.updateSwipeDecisions(decisions),
          );
        }

      case 'vuln_spotter':
        {
          final elements = (question.payload['elements'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];
          final totalVulns = question.payload['total_vulns'] as int? ?? 1;
          final description = question.payload['description'] as String? ?? '';
          return VulnSpotterWidget(
            description: description,
            elements: elements,
            totalVulns: totalVulns,
            isChecked: controller.isChecked,
            isCorrect: controller.isCorrect,
            onVulnsFound: (foundVulns) => controller.updateFoundVulns(foundVulns),
          );
        }

      case 'network_cutter':
        {
          final nodes = (question.payload['nodes'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];
          final edges = (question.payload['edges'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ?? [];
          final targetCount = question.payload['target_count'] as int? ?? 1;
          return NetworkTopologyCutterWidget(
            nodes: nodes,
            edges: edges,
            targetCount: targetCount,
            isChecked: controller.isChecked,
            isCorrect: controller.isCorrect,
            onEdgesCut: (cutEdges) => controller.updateCutEdges(cutEdges),
          );
        }
      
      case 'log_anomaly':
        {
          final lines = (question.payload['lines'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final correctIndex = question.payload['correct_index'] as int?;

          return LogAnomalyWidget(
            lines: lines,
            selectedIndex: controller.selectedOptionIndex,
            isChecked: controller.isChecked,
            isCorrect: controller.isCorrect,
            correctIndex: correctIndex,
            onLineSelected: (index) => controller.selectOption(index),
          );
        }

      default:
        return Text('Tipe pertanyaan tidak didukung: ${question.type}');
    }
  }

  /// Bottom button: "Periksa" before check, "Lanjutkan" after check
  String? _getCorrectAnswerText(LessonController controller) {
    final q = controller.currentQuestion;
    if (q == null) return null;

    if (q.type == 'log_anomaly') {
      return q.payload['correct_answer']?.toString();
    }

    return null;
  }

  /// Button "Periksa" (Check)
  /// Only shown when feedback is NOT yet visible
  Widget _buildCheckButton(LessonController controller) {
    final hasAnswer =
        controller.selectedOptionIndex != null ||
        (controller.userSwipeDecisions != null &&
            controller.userSwipeDecisions!.isNotEmpty) ||
        (controller.userFoundVulns != null &&
            controller.userFoundVulns!.isNotEmpty) ||
        (controller.userCutEdges != null &&
            controller.userCutEdges!.isNotEmpty);

    final VoidCallback? onPressed =
        hasAnswer && controller.canAnswer && controller.hasHearts
        ? () {
            controller.checkAnswer();
            if (controller.isCorrect) {
              QuizHapticService.correctFeedback();
            } else {
              QuizHapticService.wrongFeedback();
              _shakeKey.currentState?.shake(); // 📳 Shake input
            }
          }
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Color(0xFF30363D))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF161B22),
            foregroundColor: const Color(0xFF3FB950),
            disabledBackgroundColor: const Color(0xFF161B22),
            disabledForegroundColor: const Color(0xFF30363D),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: onPressed != null ? const Color(0xFF30363D) : const Color(0xFF21262D)),
            ),
            elevation: 0,
          ),
          child: Text(
            "[ RUN SYSTEM SECURITY AUDIT ]",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context, LessonController controller) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tunggu Dulu!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Progress kamu akan hilang jika keluar sekarang.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              DuoButton(
                text: 'TETAP BELAJAR',
                variant: DuoButtonVariant.green,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
              DuoButton(
                text: 'AKHIRI SESI',
                variant: DuoButtonVariant.red,
                onPressed: () {
                  controller.exitLesson();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatrixBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3FB950).withOpacity(0.025);
    final rng = Random(42);
    for (double y = 0; y < size.height; y += 18) {
      for (double x = 0; x < size.width; x += 14) {
        if (rng.nextDouble() < 0.3) {
          final text = String.fromCharCode(rng.nextInt(2) + 48);
          final tp = TextPainter(
            text: TextSpan(text: text, style: TextStyle(color: paint.color, fontSize: 10, fontFamily: 'JetBrainsMono')),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x, y));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
