import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/home/data/models/training_question.dart';
import 'package:scout_os_app/features/home/data/datasources/training_service.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

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
  List<bool>? userSwipeDecisions; // Untuk Packet Sweeper
  Set<int>? userFoundVulns; // Untuk Vulnerability Spotter
  Set<int>? userCutEdges; // Untuk Network Topology Cutter

  // State AI (PradigiResponse)
  String? aiDialog;
  String? aiStatus;
  int computationalScoreChange = 0;
  int ethicalScoreChange = 0;
  bool isAiEvaluating = false;
  bool _hasAiEvaluated = false;
  String? nextObjective;
  String? threatMutation;
  String? adaptiveNarrative;
  int difficultyAdjustment = 0;
  String? _previousThreatType;
  int streakCorrect = 0;
  int streakWrong = 0;

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

  bool get hasHearts => true; // Unlimited Hearts Mode
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

  /// Update swipe decisions for Packet Sweeper
  void updateSwipeDecisions(List<bool> decisions) {
    if (isChecked || !canAnswer) return;
    userSwipeDecisions = decisions;
    selectedOptionIndex = null;
    notifyListeners();
  }

  /// Update found vulnerabilities for Vulnerability Spotter
  void updateFoundVulns(Set<int> foundVulns) {
    if (isChecked || !canAnswer) return;
    userFoundVulns = foundVulns;
    selectedOptionIndex = null;
    notifyListeners();
  }

  /// Update cut edges for Network Topology Cutter
  void updateCutEdges(Set<int> cutEdges) {
    if (isChecked || !canAnswer) return;
    userCutEdges = cutEdges;
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

    // Logika Pengecekan Berdasarkan Tipe Soal
    switch (q.type) {
      case 'cipher_rotor':
        if (selectedOptionIndex != null) {
          final correctShift = q.payload['correct_shift'] as int?;
          isCorrect = selectedOptionIndex == correctShift;
        }
        break;

      case 'log_anomaly':
        if (selectedOptionIndex != null) {
          final correctIndex = q.payload['correct_index'] as int?;
          isCorrect = selectedOptionIndex == correctIndex;
        }
        break;

      case 'packet_sweeper':
        if (userSwipeDecisions != null) {
          final packets = (q.payload['packets'] as List<dynamic>?) ?? [];
          int correctCount = 0;
          for (int i = 0; i < packets.length && i < userSwipeDecisions!.length; i++) {
            final isMalicious = (packets[i] as Map)['is_malicious'] as bool? ?? false;
            final userSaidSafe = userSwipeDecisions![i];
            if (userSaidSafe == !isMalicious) correctCount++;
          }
          isCorrect = packets.isNotEmpty && (correctCount / packets.length) >= 0.8;
        }
        break;

      case 'vuln_spotter':
        if (userFoundVulns != null) {
          final elements = (q.payload['elements'] as List<dynamic>?) ?? [];
          final actualVulnIndices = <int>{};
          for (int i = 0; i < elements.length; i++) {
            if ((elements[i] as Map)['is_vuln'] == true) {
              actualVulnIndices.add(i);
            }
          }
          isCorrect = userFoundVulns!.containsAll(actualVulnIndices);
        }
        break;

      case 'network_cutter':
        if (userCutEdges != null) {
          final edges = (q.payload['edges'] as List<dynamic>?) ?? [];
          final maliciousIndices = <int>{};
          for (int i = 0; i < edges.length; i++) {
            if ((edges[i] as Map)['malicious'] == true) {
              maliciousIndices.add(i);
            }
          }
          final cutAllMalicious = userCutEdges!.containsAll(maliciousIndices);
          final noBadCuts = userCutEdges!.every((i) => maliciousIndices.contains(i));
          isCorrect = cutAllMalicious && noBadCuts;
        }
        break;

      default:
        break;
    }

    // Update Score
    if (isCorrect) {
      score++;
      if (!correctQuestionIds.contains(q.id)) {
        correctQuestionIds.add(q.id);
      }
      userStreak++;
    } else {
      userStreak = 0;
    }

    isChecked = true;
    showFeedback = true;
    notifyListeners();

    // Fire AI evaluation for cyber tool types
    final cyberTypes = ['cipher_rotor', 'packet_sweeper', 'vuln_spotter', 'network_cutter', 'log_anomaly'];
    if (cyberTypes.contains(q.type) && !_hasAiEvaluated) {
      _evaluateWithAI(q);
    }
  }

  Future<void> _evaluateWithAI(TrainingQuestion q) async {
    if (_hasAiEvaluated) return;
    _hasAiEvaluated = true;

    isAiEvaluating = true;
    notifyListeners();

    try {
      final dio = ApiDioProvider.getDio();
      final userPayload = _buildUserPayload(q);

      final response = await dio.post(
        '/game/play',
        data: {
          'question_id': q.id,
          'tool_type': q.type,
          'user_payload': userPayload,
          'history': <Map<String, String>>[],
          'session_score': score,
          'streak_correct': streakCorrect,
          'streak_wrong': streakWrong,
          'previous_threat': _previousThreatType ?? '',
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        final aiResponse = data['data']['ai_response'];
        if (aiResponse is Map) {
          aiDialog = aiResponse['dialog_ai']?.toString();
          aiStatus = aiResponse['status_simulasi']?.toString();
          computationalScoreChange = (aiResponse['computational_score_change'] as num?)?.toInt() ?? 0;
          ethicalScoreChange = (aiResponse['ethical_score_change'] as num?)?.toInt() ?? 0;
          nextObjective = aiResponse['next_objective']?.toString();
          threatMutation = aiResponse['threat_mutation']?.toString();
          adaptiveNarrative = aiResponse['adaptive_narrative']?.toString();
          difficultyAdjustment = (aiResponse['difficulty_adjustment'] as num?)?.toInt() ?? 0;

          if (aiStatus == 'berhasil') {
            isCorrect = true;
            streakCorrect++;
            streakWrong = 0;
            if (!correctQuestionIds.contains(q.id)) {
              correctQuestionIds.add(q.id);
            }
          } else if (aiStatus == 'gagal') {
            isCorrect = false;
            streakWrong++;
            streakCorrect = 0;
          }

          _previousThreatType = q.type;

          debugPrint('[AI] status: $aiStatus, next: $nextObjective, mutation: $threatMutation, difficulty: $difficultyAdjustment');
        }
      }
    } catch (e) {
      debugPrint('[AI] evaluation failed (using local fallback): $e');
      aiDialog = null;
      aiStatus = null;
    } finally {
      isAiEvaluating = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildUserPayload(TrainingQuestion q) {
    switch (q.type) {
      case 'cipher_rotor':
        return {
          'encrypted_text': q.payload['encrypted_text'],
          'correct_shift': q.payload['correct_shift'],
          'user_shift': selectedOptionIndex,
          'decrypted_text': _decryptCaesar(
            q.payload['encrypted_text']?.toString() ?? '',
            selectedOptionIndex ?? 0,
          ),
        };

      case 'log_anomaly':
        return {
          'lines': q.payload['lines'],
          'correct_index': q.payload['correct_index'],
          'selected_index': selectedOptionIndex,
        };

      case 'packet_sweeper':
        {
          final packets = q.payload['packets'] as List<dynamic>? ?? [];
          final decisions = <Map<String, dynamic>>[];
          for (int i = 0; i < packets.length; i++) {
            final p = packets[i] as Map;
            decisions.add({
              'index': i,
              'protocol': p['protocol'],
              'src_ip': p['src_ip'],
              'dst_ip': p['dst_ip'],
              'is_malicious': p['is_malicious'] ?? false,
              'user_said_safe': i < (userSwipeDecisions?.length ?? 0)
                  ? userSwipeDecisions![i]
                  : false,
            });
          }
          return {'packets': decisions};
        }

      case 'vuln_spotter':
        {
          final elements = q.payload['elements'] as List<dynamic>? ?? [];
          final vulnsFound = userFoundVulns ?? <int>{};
          final missedVulns = <int>{};
          for (int i = 0; i < elements.length; i++) {
            if ((elements[i] as Map)['is_vuln'] == true && !vulnsFound.contains(i)) {
              missedVulns.add(i);
            }
          }
          return {
            'elements_scanned': elements.length,
            'vulns_found': vulnsFound.toList(),
            'vulns_missed': missedVulns.toList(),
            'total_vulns': q.payload['total_vulns'],
          };
        }

      case 'network_cutter':
        {
          final edges = q.payload['edges'] as List<dynamic>? ?? [];
          final cut = userCutEdges ?? <int>{};
          final maliciousCut = <int>{};
          final safeCut = <int>{};
          for (int i = 0; i < edges.length; i++) {
            if (cut.contains(i)) {
              if ((edges[i] as Map)['malicious'] == true) {
                maliciousCut.add(i);
              } else {
                safeCut.add(i);
              }
            }
          }
          return {
            'total_edges': edges.length,
            'edges_cut': cut.toList(),
            'malicious_cut': maliciousCut.toList(),
            'safe_cut_by_mistake': safeCut.toList(),
          };
        }

      default:
        return q.payload;
    }
  }

  String _decryptCaesar(String text, int shift) {
    final buffer = StringBuffer();
    for (var code in text.runes) {
      final char = String.fromCharCode(code);
      if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
        final isUpper = char == char.toUpperCase();
        final base = isUpper ? 65 : 97;
        final decoded = (code - base - shift + 26) % 26 + base;
        buffer.write(String.fromCharCode(decoded));
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
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

  // Helper untuk Caesar decrypt

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
    userSwipeDecisions = null;
    userFoundVulns = null;
    userCutEdges = null;
    isChecked = false;
    isCorrect = false;
    _lastAnswerTime = null;
    aiDialog = null;
    aiStatus = null;
    computationalScoreChange = 0;
    ethicalScoreChange = 0;
    isAiEvaluating = false;
    _hasAiEvaluated = false;
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
