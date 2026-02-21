import 'package:flutter/material.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/home/data/models/training_question.dart';
import 'package:scout_os_app/features/home/data/datasources/training_service.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';

class LessonController extends ChangeNotifier {
  // Gunakan Service, bukan Repository (sesuai struktur sebelumnya)
  final TrainingService _service = TrainingService();
  final AuthRepository _authRepo = AuthRepository();

  LessonController({TrainingController? trainingController});

  List<TrainingQuestion> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  String? errorMessage;
  String lessonId = ""; // Ubah ke String agar cocok dengan "puk_u1_l1"

  // ✅ CRITICAL: Track which question IDs were answered correctly
  List<String> correctQuestionIds = [];

  // Duolingo-style progress tracking
  int userXp = 0;
  int userStreak = 0;
  int userHearts = 5;
  int maxHearts = 5;

  // State Jawaban User
  int? selectedOptionIndex; // Untuk Multiple Choice (Index tombol)
  String? userAnswerString; // Untuk Input Teks
  List<String>? userSortingOrder; // Untuk Soal Sorting (Drag & Drop)
  Map<String, String>? userMatchingPairs; // Untuk Soal Matching

  // State UI
  bool isChecked = false;
  bool isCorrect = false;
  bool isCompleted = false;
  bool showFeedback = false;

  // Anti-cheat: Delay
  DateTime? _lastAnswerTime;
  static const Duration _answerDelay = Duration(milliseconds: 500);
  bool get canAnswer =>
      _lastAnswerTime == null ||
      DateTime.now().difference(_lastAnswerTime!) >= _answerDelay;

  // ✅ Deduplication lock - prevents double submit
  bool _isSubmitting = false;

  // ✅ Store backend response for optimistic UI updates
  String? _lastCompletedStatus;
  String? _lastNextLevelId;

  // ⏱ Quiz timer
  DateTime? _quizStartTime;
  int get elapsedSeconds => _quizStartTime != null
      ? DateTime.now().difference(_quizStartTime!).inSeconds
      : 0;

  /// Status returned by backend after finishLesson (e.g. 'COMPLETED', 'UNLOCKED')
  String? get lastCompletedStatus => _lastCompletedStatus;

  /// Next level ID unlocked by backend after finishLesson
  String? get lastNextLevelId => _lastNextLevelId;

  bool get hasHearts => userHearts > 0;

  double get progress =>
      questions.isEmpty ? 0.0 : (currentQuestionIndex + 1) / questions.length;

  TrainingQuestion? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

  // ✅ Public getter for currentLevelId (used by UI for optimistic unlocking)
  String? get currentLevelId => _resolveCurrentLevelId();

  // ==========================================
  // 1. FETCH DATA (REAL API)
  // ==========================================
  Future<void> loadQuestions(String levelId) async {
    lessonId = levelId;
    isLoading = true;
    errorMessage = null;
    questions = []; // Reset questions
    notifyListeners();

    try {
      // CRITICAL: Trim levelId to prevent whitespace issues
      final cleanLevelId = levelId.trim();
      debugPrint(
        '🔍 LessonController.loadQuestions() called with levelId: "$cleanLevelId"',
      );

      // Panggil API Backend: GET /api/v1/training/levels/{id}/questions
      final fetchedQuestions = await _service.fetchQuestions(cleanLevelId);

      // DEFENSIVE FILTERING: Double-check that all questions belong to this level
      // This is a safety measure in case the service layer doesn't filter properly
      // CRITICAL: Use STRICT EQUALITY (==) with trimmed values
      final filteredQuestions = fetchedQuestions
          .where((q) => q.levelId.trim() == cleanLevelId)
          .toList();

      // DEBUG LOGGING: Help diagnose data leak issues
      debugPrint('🔍 LessonController filtering results:');
      debugPrint(
        '   📊 Fetched from service: ${fetchedQuestions.length} questions',
      );
      debugPrint(
        '   ✅ After strict filtering: ${filteredQuestions.length} questions',
      );
      if (fetchedQuestions.isNotEmpty) {
        final uniqueLevelIds = fetchedQuestions.map((q) => q.levelId).toSet();
        debugPrint('   📋 Found levelIds: ${uniqueLevelIds.join(", ")}');
        if (filteredQuestions.isNotEmpty) {
          debugPrint('   ✅ Filtered questions (first 3):');
          filteredQuestions.take(3).forEach((q) {
            debugPrint(
              '      - QID: ${q.id} | LevelID: "${q.levelId}" | Order: ${q.order}',
            );
          });
        }
      }

      // ⏱ Start timer when questions are ready
      _quizStartTime = DateTime.now();

      if (filteredQuestions.isEmpty) {
        if (fetchedQuestions.isNotEmpty) {
          // Backend returned questions but none match the levelId
          final uniqueLevelIds = fetchedQuestions.map((q) => q.levelId).toSet();
          errorMessage =
              "Backend mengembalikan ${fetchedQuestions.length} soal, tetapi tidak ada yang cocok dengan level '$cleanLevelId'.";
          debugPrint(
            "⚠️ Level ID mismatch: Expected '$cleanLevelId', but got questions with levelIds: ${uniqueLevelIds.join(", ")}",
          );
        } else {
          errorMessage =
              "Level ini belum memiliki soal. Silakan coba level lain.";
        }
      } else {
        // CRITICAL: Sort by order field to maintain exact sequence from database
        // Backend already orders by order field, but we ensure it here as well
        filteredQuestions.sort((a, b) => a.order.compareTo(b.order));
        questions = filteredQuestions;
        questions = filteredQuestions;
        debugPrint(
          '✅ Successfully loaded ${questions.length} questions for level "$cleanLevelId"',
        );

        // ✅ Sync hearts with backend
        _loadUserHearts();
      }
    } on Exception catch (e) {
      // Parse backend error messages
      final errorString = e.toString();

      if (errorString.contains('404') || errorString.contains('not found')) {
        errorMessage = "Level '$levelId' tidak ditemukan atau tidak aktif.";
      } else if (errorString.contains('timeout') ||
          errorString.contains('Connection timeout')) {
        errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
      } else if (errorString.contains('SocketException') ||
          errorString.contains('NetworkException')) {
        errorMessage =
            "Tidak dapat terhubung ke server. Pastikan backend berjalan.";
      } else if (errorString.contains('FormatException') ||
          errorString.contains('JSON')) {
        errorMessage = "Data dari server tidak valid. Hubungi administrator.";
      } else {
        errorMessage = "Gagal memuat soal. Coba lagi nanti.";
      }

      debugPrint("❌ API Error: $e");
    } catch (e) {
      errorMessage =
          "Terjadi kesalahan tidak terduga: ${e.toString().substring(0, 50)}...";
      debugPrint("❌ Unexpected Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load all questions from a unit (all levels combined)
  ///
  /// This is useful when you want to show all questions from a unit in one quiz session.
  /// Endpoint: GET /api/v1/training/units/{unitId}/questions
  Future<void> loadQuestionsByUnit(String unitId) async {
    lessonId = unitId; // Store unitId as lessonId for compatibility
    isLoading = true;
    errorMessage = null;
    questions = []; // Reset questions
    notifyListeners();

    try {
      // Panggil API Backend: GET /api/v1/training/units/{unitId}/questions
      final fetchedQuestions = await _service.fetchQuestionsByUnit(unitId);

      // ⏱ Start timer when questions are ready
      _quizStartTime = DateTime.now();

      if (fetchedQuestions.isEmpty) {
        errorMessage = "Unit ini belum memiliki soal. Silakan coba unit lain.";
      } else {
        questions = fetchedQuestions;
        // ✅ Sync hearts with backend
        _loadUserHearts();
      }
    } on Exception catch (e) {
      // Parse backend error messages
      final errorString = e.toString();

      if (errorString.contains('404') || errorString.contains('not found')) {
        errorMessage = "Unit '$unitId' tidak ditemukan atau tidak aktif.";
      } else if (errorString.contains('timeout') ||
          errorString.contains('Connection timeout')) {
        errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
      } else if (errorString.contains('SocketException') ||
          errorString.contains('NetworkException')) {
        errorMessage =
            "Tidak dapat terhubung ke server. Pastikan backend berjalan.";
      } else if (errorString.contains('FormatException') ||
          errorString.contains('JSON')) {
        errorMessage = "Data dari server tidak valid. Hubungi administrator.";
      } else {
        errorMessage = "Gagal memuat soal. Coba lagi nanti.";
      }

      debugPrint("❌ API Error: $e");
    } catch (e) {
      errorMessage =
          "Terjadi kesalahan tidak terduga: ${e.toString().substring(0, 50)}...";
      debugPrint("❌ Unexpected Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. USER INTERACTION
  // ==========================================

  void selectOption(int index) {
    if (isChecked || !canAnswer) return;
    selectedOptionIndex = index;
    userAnswerString = null;
    userSortingOrder = null;
    notifyListeners();
  }

  void updateSortingOrder(List<String> items) {
    if (isChecked || !canAnswer) return;
    userSortingOrder = items;
    selectedOptionIndex = null;
    notifyListeners();
  }

  /// Update string answer for input-type questions
  void updateStringAnswer(String answer) {
    if (isChecked || !canAnswer) return;
    userAnswerString = answer;
    selectedOptionIndex = null;
    notifyListeners();
  }

  /// Update matching answers
  void updateMatchingAnswer(Map<String, String> pairs) {
    if (isChecked || !canAnswer) return;
    userMatchingPairs = pairs;
    selectedOptionIndex = null;
    notifyListeners();
  }

  // ==========================================
  // 3. CHECK ANSWER LOGIC
  // ==========================================
  void checkAnswer() {
    if (currentQuestion == null || isChecked || !canAnswer) return;

    _lastAnswerTime = DateTime.now();
    final q = currentQuestion!;
    isCorrect = false;

    // Logika Pengecekan Berdasarkan Tipe Soal Backend
    switch (q.type) {
      case 'sorting':
        // Bandingkan urutan user dengan urutan asli di payload['items']
        // Backend mengirim items dalam urutan BENAR. Frontend mengacaknya.
        if (userSortingOrder != null) {
          final correctOrder = List<String>.from(q.payload['items'] ?? []);
          // Bandingkan list string secara presisi
          isCorrect = _compareLists(userSortingOrder!, correctOrder);
        }
        break;

      case 'fill_blank':
      case 'input':
      case 'text_input':
        if (userAnswerString != null) {
          final correct = q.payload['correct_answer']?.toString() ?? '';
          final caseSensitive = q.payload['case_sensitive'] == true;
          final user = userAnswerString ?? '';
          isCorrect = caseSensitive
              ? user.trim() == correct.trim()
              : _normalizeText(user) == _normalizeText(correct);
        }
        break;

      case 'word_bank':
      case 'arrange_words':
        if (userAnswerString != null) {
          final correctOrder = List<String>.from(
            q.payload['correct_order'] ?? q.payload['words'] ?? [],
          );
          final userWords = _splitWords(userAnswerString ?? '');
          isCorrect = _compareLists(
            userWords.map(_normalizeText).toList(),
            correctOrder.map(_normalizeText).toList(),
          );
        }
        break;

      case 'matching':
        if (userMatchingPairs != null) {
          final pairs = List<Map<String, dynamic>>.from(
            q.payload['pairs'] ?? [],
          );
          bool allMatch = true;

          debugPrint(
            '🔍 [CHECK_MATCHING] Validating payload pairs against user answers:',
          );

          for (final pair in pairs) {
            final left = pair['left']?.toString().trim() ?? '';
            final right = pair['right']?.toString().trim() ?? '';
            // ✅ Hot Reload: Matching debug added

            // Get user's answer for this left key (also trimmed)
            final userRight = userMatchingPairs?[left]?.trim();
            // Fallback: iterate user map to find key match if trimming differs slightly
            final userRightFallback = userMatchingPairs?.entries
                .firstWhere(
                  (e) => e.key.trim() == left,
                  orElse: () => const MapEntry('', ''),
                )
                .value
                .trim();

            final actualUserRight =
                userRight ??
                (userRightFallback?.isNotEmpty == true
                    ? userRightFallback
                    : null);

            debugPrint(
              '   - Key: "$left" | Expected: "$right" | User: "${actualUserRight ?? 'NULL'}"',
            );

            if (actualUserRight != right) {
              debugPrint('     ❌ MISMATCH!');
              allMatch = false;
              // Don't break immediately so we can see other mismatches in debug
            }
          }
          isCorrect = allMatch;
        } else {
          debugPrint('❌ [CHECK_MATCHING] userMatchingPairs is NULL');
        }
        break;

      case 'multiple_choice':
      default:
        // Bandingkan teks pilihan yang dipilih user dengan kunci jawaban
        if (selectedOptionIndex != null) {
          final options = List<String>.from(q.payload['options'] ?? []);
          if (selectedOptionIndex! < options.length) {
            final userSelectedText = options[selectedOptionIndex!];
            final correctAnswerText = q.payload['correct_answer'];
            isCorrect = userSelectedText == correctAnswerText;
          }
        }
        break;
    }

    // Update Score & Hearts
    // ✅ CRITICAL: XP is NOT calculated here - it comes from backend response only
    if (isCorrect) {
      score++;
      // ✅ CRITICAL: Track question ID if answered correctly
      if (!correctQuestionIds.contains(q.id)) {
        correctQuestionIds.add(q.id);
        debugPrint('✅ [CHECK_ANSWER] Added correct question ID: ${q.id}');
      }
      // ✅ REMOVED: userXp += q.xp; - XP must ONLY come from backend response
      userStreak++;
    } else {
      // Strict Sync: Decrement hearts directly
      userHearts = (userHearts - 1).clamp(0, maxHearts);

      // ✅ Critical: Update local cache immediately so TrainingPage sees the change
      _preserveHeartsLocally();

      // Fire-and-forget: sync hearts decrement to backend
      _decrementHeartsOnBackend();

      userStreak = 0;
    }

    isChecked = true;
    showFeedback = true;
    notifyListeners();
  }

  /// Save hearts to local cache to keep TrainingController in sync
  Future<void> _preserveHeartsLocally() async {
    try {
      await LocalCacheService.put('user_hearts', userHearts);
      debugPrint('💚 [LESSON_SYNC] Saved hearts to cache: $userHearts');
    } catch (e) {
      debugPrint('⚠️ [LESSON_SYNC] Failed to save hearts/cache: $e');
    }
  }

  /// Fire-and-forget: decrement hearts on backend
  Future<void> _loadUserHearts() async {
    try {
      final currentUser = await _authRepo.getCurrentUser();
      final userId = currentUser.id;
      if (userId.isNotEmpty) {
        final result = await _service.getHearts(userId: userId);
        if (result.containsKey('hearts')) {
          userHearts = result['hearts'] as int;
          // Sync with local cache as backup
          await LocalCacheService.put('user_hearts', userHearts);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [HEARTS] Failed to load hearts: $e');
    }
  }

  /// Fire-and-forget: decrement hearts on backend
  void _decrementHeartsOnBackend() {
    Future(() async {
      try {
        final currentUser = await _authRepo.getCurrentUser();
        final userId = currentUser.id;
        if (userId.isNotEmpty) {
          final result = await _service.decrementHearts(userId: userId);
          // ✅ Sync local state with backend response
          if (result.containsKey('hearts')) {
            userHearts = result['hearts'] as int;
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('⚠️ [HEARTS] Backend decrement failed (non-critical): $e');
      }
    });
  }

  // Helper untuk membandingkan 2 List String
  bool _compareLists(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  String _normalizeText(String input) {
    return input.trim().toLowerCase();
  }

  List<String> _splitWords(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  // ==========================================
  // 4. NAVIGATION
  // ==========================================
  Future<void> nextQuestion() async {
    if (!isChecked) return;

    showFeedback = false;

    if (currentQuestionIndex < questions.length - 1) {
      // Lanjut soal berikutnya
      currentQuestionIndex++;
      _resetAnswerState();
      notifyListeners();
    } else {
      // Selesai Level
      isCompleted = true;

      // ✅ REMOVED: _submitProgressToBackend() - finishLesson will handle it
      // Progress submission is done in finishLesson() which is called by UI

      notifyListeners();
    }
  }

  /// Finish lesson and calculate XP reward
  ///
  /// Returns: XP earned (0 if level was previously completed, otherwise level's xpReward)
  ///
  /// **Single API Architecture:**
  /// - ONLY calls submitProgress (backend handles streak + XP)
  /// - NO getUserStats, NO updateUserXp, NO loadPathData
  Future<int> finishLesson({required bool isSuccess}) async {
    // ✅ Deduplication guard - prevent double submit
    if (_isSubmitting) {
      debugPrint('⚠️ [FINISH] Already submitting, skipping duplicate call');
      return 0;
    }

    int xpEarned = 0;
    _isSubmitting = true;

    try {
      if (!isSuccess || questions.isEmpty) {
        debugPrint(
          '⚠️ [FINISH] finishLesson skipped: isSuccess=$isSuccess, questions.isEmpty=${questions.isEmpty}',
        );
        return 0;
      }

      // Get userId from JWT token via AuthRepository
      String userId;
      try {
        final currentUser = await _authRepo.getCurrentUser();
        userId = currentUser.id;
        debugPrint('✅ [FINISH] Got userId from JWT: $userId');
      } catch (e) {
        debugPrint('❌ [FINISH] Failed to get userId from JWT: $e');
        return 0;
      }

      if (userId.isEmpty) {
        debugPrint('❌ [FINISH] Empty userId, cannot save progress');
        return 0;
      }

      final currentLevelId = _resolveCurrentLevelId();
      if (currentLevelId == null) {
        debugPrint('❌ [FINISH] Could not resolve currentLevelId');
        return 0;
      }

      debugPrint(
        '🎯 [FINISH] Starting finishLesson for level: $currentLevelId',
      );

      // ✅ Step 1: SINGLE API CALL - submitProgress returns EVERYTHING
      // Backend handles: XP, streak calculation, last_active_date update, AND unlocking next level
      try {
        final correctAnswers = score;
        final totalQuestions = questions.length;

        debugPrint(
          '📊 [FINISH] Submitting progress: level=$currentLevelId, score=$score/$totalQuestions',
        );
        debugPrint('📊 [FINISH] Correct question IDs: $correctQuestionIds');

        final response = await _service.submitProgress(
          levelId: currentLevelId,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          correctQuestionIds: correctQuestionIds,
          timeSpentSeconds: 0,
        );

        // ✅ Get ALL data from backend response
        xpEarned = response['xp_earned'] as int? ?? 0;
        final totalXp = response['total_xp'] as int? ?? 0;
        final streak = response['streak'] as int? ?? 0;
        final status = response['status'] as String? ?? 'UNLOCKED';
        final nextLevelId = response['next_level_id'] as String?;

        debugPrint('✅ [FINISH] Backend response:');
        debugPrint('   status=$status, xp_earned=$xpEarned, total_xp=$totalXp');
        debugPrint('   streak=$streak, next_level_id=$nextLevelId');

        // ✅ Update local stats for display
        userXp = totalXp;
        userStreak = streak;

        // ✅ Store completion status for optimistic UI
        _lastCompletedStatus = status;
        _lastNextLevelId = nextLevelId;
      } catch (e, stackTrace) {
        debugPrint('❌ [FINISH] Error submitting progress: $e');
        debugPrint('   Stack trace: $stackTrace');
      }

      debugPrint('✅ [FINISH] finishLesson completed. XP Earned: $xpEarned');
      return xpEarned;
    } catch (e, stackTrace) {
      debugPrint('❌ [FINISH] Unexpected error: $e');
      debugPrint('   Stack trace: $stackTrace');
      return 0;
    } finally {
      _isSubmitting = false;
    }
  }

  // ✅ REMOVED: _unlockNextLevel
  // Next level unlocking is handled by Backend (Redis Invalidation) + Frontend Force Refresh

  // REMOVED: _tryAlternativeUnitId, _extractUnitId - Unused

  String? _resolveCurrentLevelId() {
    if (lessonId.isEmpty) return null;
    if (questions.isNotEmpty) {
      return questions.first.levelId;
    }
    return lessonId;
  }

  void _resetAnswerState() {
    selectedOptionIndex = null;
    userAnswerString = null;
    userSortingOrder = null;
    userMatchingPairs = null;
    isChecked = false;
    isCorrect = false;
    _lastAnswerTime = null;
  }

  void exitLesson() {
    currentQuestionIndex = 0;
    score = 0;
    correctQuestionIds.clear(); // ✅ Reset correct question IDs
    _resetAnswerState();
    isCompleted = false;
    showFeedback = false;
    errorMessage = null;
    notifyListeners();
  }
}
