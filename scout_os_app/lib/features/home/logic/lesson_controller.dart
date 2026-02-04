import 'package:flutter/material.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/core/auth/local_auth_service.dart';
import 'package:scout_os_app/features/home/data/models/training_question.dart';
import 'package:scout_os_app/features/home/data/datasources/training_service.dart';
import 'package:scout_os_app/features/home/data/repositories/training_repository.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';

class LessonController extends ChangeNotifier {
  // Gunakan Service, bukan Repository (sesuai struktur sebelumnya)
  final TrainingService _service = TrainingService();
  final TrainingRepository _repository = TrainingRepository();
  final AuthRepository _authRepo = AuthRepository();
  final LocalAuthService _localAuthService = LocalAuthService();
  final ProfileRepository _profileRepo = ProfileRepository();
  
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
  bool get canAnswer => _lastAnswerTime == null || 
      DateTime.now().difference(_lastAnswerTime!) >= _answerDelay;

  bool get hasHearts => userHearts > 0;
  
  double get progress => questions.isEmpty 
      ? 0.0 
      : (currentQuestionIndex + 1) / questions.length;

  TrainingQuestion? get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : null;

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
      debugPrint('🔍 LessonController.loadQuestions() called with levelId: "$cleanLevelId"');
      
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
      debugPrint('   📊 Fetched from service: ${fetchedQuestions.length} questions');
      debugPrint('   ✅ After strict filtering: ${filteredQuestions.length} questions');
      if (fetchedQuestions.isNotEmpty) {
        final uniqueLevelIds = fetchedQuestions.map((q) => q.levelId).toSet();
        debugPrint('   📋 Found levelIds: ${uniqueLevelIds.join(", ")}');
        if (filteredQuestions.isNotEmpty) {
          debugPrint('   ✅ Filtered questions (first 3):');
          filteredQuestions.take(3).forEach((q) {
            debugPrint('      - QID: ${q.id} | LevelID: "${q.levelId}" | Order: ${q.order}');
          });
        }
      }
      
      if (filteredQuestions.isEmpty) {
        if (fetchedQuestions.isNotEmpty) {
          // Backend returned questions but none match the levelId
          final uniqueLevelIds = fetchedQuestions.map((q) => q.levelId).toSet();
          errorMessage = "Backend mengembalikan ${fetchedQuestions.length} soal, tetapi tidak ada yang cocok dengan level '$cleanLevelId'.";
          debugPrint("⚠️ Level ID mismatch: Expected '$cleanLevelId', but got questions with levelIds: ${uniqueLevelIds.join(", ")}");
        } else {
          errorMessage = "Level ini belum memiliki soal. Silakan coba level lain.";
        }
      } else {
        // CRITICAL: Sort by order field to maintain exact sequence from database
        // Backend already orders by order field, but we ensure it here as well
        filteredQuestions.sort((a, b) => a.order.compareTo(b.order));
        questions = filteredQuestions;
        debugPrint('✅ Successfully loaded ${questions.length} questions for level "$cleanLevelId"');
      }
    } on Exception catch (e) {
      // Parse backend error messages
      final errorString = e.toString();
      
      if (errorString.contains('404') || errorString.contains('not found')) {
        errorMessage = "Level '$levelId' tidak ditemukan atau tidak aktif.";
      } else if (errorString.contains('timeout') || errorString.contains('Connection timeout')) {
        errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
      } else if (errorString.contains('SocketException') || errorString.contains('NetworkException')) {
        errorMessage = "Tidak dapat terhubung ke server. Pastikan backend berjalan.";
      } else if (errorString.contains('FormatException') || errorString.contains('JSON')) {
        errorMessage = "Data dari server tidak valid. Hubungi administrator.";
      } else {
        errorMessage = "Gagal memuat soal. Coba lagi nanti.";
      }
      
      debugPrint("❌ API Error: $e");
    } catch (e) {
      errorMessage = "Terjadi kesalahan tidak terduga: ${e.toString().substring(0, 50)}...";
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
      
      if (fetchedQuestions.isEmpty) {
        errorMessage = "Unit ini belum memiliki soal. Silakan coba unit lain.";
      } else {
        questions = fetchedQuestions;
      }
    } on Exception catch (e) {
      // Parse backend error messages
      final errorString = e.toString();
      
      if (errorString.contains('404') || errorString.contains('not found')) {
        errorMessage = "Unit '$unitId' tidak ditemukan atau tidak aktif.";
      } else if (errorString.contains('timeout') || errorString.contains('Connection timeout')) {
        errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
      } else if (errorString.contains('SocketException') || errorString.contains('NetworkException')) {
        errorMessage = "Tidak dapat terhubung ke server. Pastikan backend berjalan.";
      } else if (errorString.contains('FormatException') || errorString.contains('JSON')) {
        errorMessage = "Data dari server tidak valid. Hubungi administrator.";
      } else {
        errorMessage = "Gagal memuat soal. Coba lagi nanti.";
      }
      
      debugPrint("❌ API Error: $e");
    } catch (e) {
      errorMessage = "Terjadi kesalahan tidak terduga: ${e.toString().substring(0, 50)}...";
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
          final pairs = List<Map<String, dynamic>>.from(q.payload['pairs'] ?? []);
          bool allMatch = true;
          for (final pair in pairs) {
            final left = pair['left']?.toString() ?? '';
            final right = pair['right']?.toString() ?? '';
            if (userMatchingPairs?[left] != right) {
              allMatch = false;
              break;
            }
          }
          isCorrect = allMatch;
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
      userHearts = (userHearts - 1).clamp(0, maxHearts);
      userStreak = 0;
    }

    isChecked = true;
    showFeedback = true;
    notifyListeners();
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
      
      // Submit progress to backend
      _submitProgressToBackend();
      
      notifyListeners();
    }
  }

  /// Calculate new streak based on last active date
  /// 
  /// Rules:
  /// - Case A: Already played today -> Keep current streak
  /// - Case B: Played yesterday -> Streak + 1
  /// - Case C: Broken streak or first time -> Set streak = 1
  int _calculateNewStreak(int currentStreak, DateTime? lastActiveDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastActiveDate == null) {
      // First time playing
      debugPrint('🔥 [STREAK] First time playing - Setting streak to 1');
      return 1;
    }
    
    // Normalize lastActiveDate to remove time component
    final lastActive = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );
    
    // Case A: Already played today
    if (lastActive.year == today.year && 
        lastActive.month == today.month && 
        lastActive.day == today.day) {
      debugPrint('🔥 [STREAK] Already played today - Keeping streak: $currentStreak');
      return currentStreak;
    }
    
    // Case B: Played yesterday
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastActive.year == yesterday.year && 
        lastActive.month == yesterday.month && 
        lastActive.day == yesterday.day) {
      final newStreak = currentStreak + 1;
      debugPrint('🔥 [STREAK] Played yesterday - Incrementing streak: $currentStreak -> $newStreak');
      return newStreak;
    }
    
    // Case C: Broken streak (last active is older than yesterday)
    debugPrint('🔥 [STREAK] Streak broken (last active: ${lastActive.toIso8601String().split('T')[0]}) - Resetting to 1');
    return 1;
  }

  /// Finish lesson and calculate XP reward
  /// 
  /// Returns: XP earned (0 if level was previously completed, otherwise level's xpReward)
  /// 
  /// **Anti-Farming Logic:**
  /// - Checks previous status BEFORE saving
  /// - XP is ONLY awarded if previous status != 'completed'
  /// - Updates user stats (XP + Streak) via LocalAuthService
  Future<int> finishLesson({required bool isSuccess}) async {
    int xpEarned = 0; // Default: no XP if failed or already completed
    
    try {
      if (!isSuccess || questions.isEmpty) {
        debugPrint('⚠️ [FINISH] finishLesson skipped: isSuccess=$isSuccess, questions.isEmpty=${questions.isEmpty}');
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
        debugPrint('   User might not be logged in or token expired');
        return 0; // Don't throw, just return 0 XP
      }

      if (userId.isEmpty) {
        debugPrint('❌ [FINISH] Empty userId, cannot save progress');
        return 0; // Don't throw, just return 0 XP
      }

      final currentLevelId = _resolveCurrentLevelId();
      if (currentLevelId == null) {
        debugPrint('❌ [FINISH] Could not resolve currentLevelId');
        return 0; // Don't throw, just return 0 XP
      }

      debugPrint('🎯 [FINISH] Starting finishLesson for level: $currentLevelId (userId: $userId)');

      // CRITICAL: Check previous status BEFORE saving (Anti-Farming)
      String? previousStatus;
      try {
        previousStatus = await _repository.getLevelStatus(userId, currentLevelId);
        debugPrint('📊 [FINISH] Previous status for $currentLevelId: $previousStatus');
      } catch (e) {
        debugPrint('⚠️ [FINISH] Could not fetch previous status: $e (assuming not completed)');
        previousStatus = null; // Assume not completed if we can't fetch
      }

      final isFirstClear = previousStatus != 'completed';
      debugPrint('🎮 [FINISH] Is first clear: $isFirstClear (previousStatus: $previousStatus)');

      // ✅ REMOVED: XP calculation - Backend calculates XP from level.xp_reward
      // XP will be returned in submit_progress response

      // Step 1: Save current level as completed
      try {
        await _repository.saveLevelStatus(
          userId: userId,
          levelId: currentLevelId,
          status: 'completed',
        );
        debugPrint('✅ [FINISH] Level $currentLevelId marked as completed');
        
        // CRITICAL: Add small delay to ensure SharedPreferences is written
        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('❌ [FINISH] Error saving level status: $e');
        // Don't throw - continue to unlock next level even if save fails
      }

      // Step 2: Submit progress to backend and get total_xp from response
      // ✅ CRITICAL: XP must ONLY come from backend response, NOT calculated client-side
      try {
        // Calculate score and correct answers
        final correctAnswers = score;
        final totalQuestions = questions.length;
        
        debugPrint('📊 [FINISH] Submitting progress: level=$currentLevelId, score=$score/$totalQuestions');
        debugPrint('📊 [FINISH] Correct question IDs: $correctQuestionIds');
        
        // ✅ CRITICAL: Submit progress to backend with correct_question_ids
        final response = await _service.submitProgress(
          levelId: currentLevelId,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          correctQuestionIds: correctQuestionIds, // ✅ Send list of correct question IDs
          timeSpentSeconds: 0, // TODO: Track time spent
        );
        
        // ✅ Get total_xp and xp_earned from backend response (NOT calculated)
        final responseTotalXp = response['total_xp'] as int?;
        final responseXpEarned = response['xp_earned'] as int? ?? 0;
        
        debugPrint('✅ [FINISH] Backend response: total_xp=$responseTotalXp, xp_earned=$responseXpEarned');
        
        // ✅ Use xp_earned from backend response (not calculated)
        xpEarned = responseXpEarned;
        
        // ✅ Fetch current server stats for streak calculation
        final currentStats = await _profileRepo.getUserStats();
        debugPrint('📊 [FINISH] Current server stats: XP=${currentStats.totalXp}, Streak=${currentStats.streak}, LastActive=${currentStats.lastActiveDate?.toIso8601String().split('T')[0] ?? 'null'}');
        
        // Calculate new streak based on last active date
        final newStreak = _calculateNewStreak(currentStats.streak, currentStats.lastActiveDate);
        final today = DateTime.now();
        
        // ✅ Update streak and last_active_date only (XP already updated by submit_progress)
        try {
          await _profileRepo.updateUserXp(
            0, // ✅ Ignored - XP comes from submit_progress only, not from this call
            newStreak: newStreak,
            lastActiveDate: today,
          );
          debugPrint('✅ [FINISH] Streak and last_active_date updated: Streak=$newStreak, LastActive=${today.toIso8601String().split('T')[0]}');
        } catch (e) {
          debugPrint('⚠️ [FINISH] Error updating streak: $e');
          // Don't throw - streak update is not critical
        }
        
        // ✅ Update local stats (for backward compatibility) - Only update streak, not XP
        await _localAuthService.init();
        await _localAuthService.updateUserStats(
          userId: userId,
          xpEarned: 0, // ✅ Don't add XP - XP comes from backend only
        );
        debugPrint('✅ [FINISH] Local stats updated (streak only)');
        
      } catch (e) {
        debugPrint('⚠️ [FINISH] Error submitting progress or updating stats: $e');
        // Don't throw - continue with unlock next level
      }

      // Step 3: Find and unlock next level
      try {
        await _unlockNextLevel(currentLevelId, userId);
        
        // CRITICAL: Add delay after unlock to ensure SharedPreferences is written
        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        debugPrint('❌ [FINISH] Error unlocking next level: $e');
        // Don't throw - unlocking is not critical for lesson completion
      }

      debugPrint('✅ [FINISH] finishLesson completed successfully. XP Earned: $xpEarned');
      return xpEarned; // Return XP earned for UI display
    } catch (e, stackTrace) {
      debugPrint('❌ [FINISH] Unexpected error in finishLesson: $e');
      debugPrint('   Stack trace: $stackTrace');
      return 0; // Return 0 XP on error
    }
  }

  /// Unlock the next level in the same unit after completing current level
  /// 
  /// ROBUST INDEX STRATEGY:
  /// 1. Get unitId from current level (prefer unitId from level data, fallback to parsing)
  /// 2. Fetch all levels in that unit from backend
  /// 3. Sort levels by level_number (or order) to ensure correct sequence
  /// 4. Find current level's index in the sorted list
  /// 5. Get next level by index (currentIndex + 1)
  /// 6. Unlock next level if status is 'locked'
  Future<void> _unlockNextLevel(String currentLevelId, String userId) async {
    try {
      debugPrint('🔍 [UNLOCK] Starting unlock process for level: $currentLevelId');

      // Step 1: Get unitId - Try to get from level data first, then parse from ID
      String? unitId;
      
      // Option A: Try to get unitId from current level data if we have questions
      if (questions.isNotEmpty) {
        // Fetch current level details to get unit_id
        try {
          final currentLevelData = await _service.fetchLevelById(currentLevelId);
          unitId = currentLevelData['unit_id'] as String?;
          debugPrint('✅ [UNLOCK] Got unitId from level data: $unitId');
        } catch (e) {
          debugPrint('⚠️ [UNLOCK] Could not fetch level data: $e');
        }
      }
      
      // Option B: Fallback to parsing from level ID
      if (unitId == null || unitId.isEmpty) {
        unitId = _extractUnitId(currentLevelId);
        if (unitId == null) {
          debugPrint('❌ [UNLOCK] Could not extract unit ID from level ID: $currentLevelId');
          return;
        }
        debugPrint('✅ [UNLOCK] Extracted unitId from level ID: $unitId');
      }

      // Step 2: Fetch all levels in the unit
      debugPrint('📡 [UNLOCK] Fetching levels for unit: $unitId');
      List<Map<String, dynamic>> levelsData = await _service.fetchLevelsByUnit(unitId);
      
      // Try alternative unit ID format if empty
      if (levelsData.isEmpty) {
        final altUnitId = _tryAlternativeUnitId(unitId);
        if (altUnitId != null && altUnitId != unitId) {
          debugPrint('🔄 [UNLOCK] Trying alternative unit ID format: $altUnitId');
          levelsData = await _service.fetchLevelsByUnit(altUnitId);
          if (levelsData.isNotEmpty) {
            unitId = altUnitId; // Update unitId for consistency
          }
        }
      }

      // Step 3: Debug - Check if we got levels
      debugPrint('📊 [UNLOCK] DEBUG: Found ${levelsData.length} levels for unit $unitId');
      if (levelsData.isEmpty) {
        debugPrint('❌ [UNLOCK] ERROR: No levels found for unit $unitId. Aborting unlock.');
        return;
      }

      // Log all level IDs for debugging
      final levelIds = levelsData.map((l) => '${l['id']} (level_number: ${l['level_number']})').join(', ');
      debugPrint('📋 [UNLOCK] Available levels: $levelIds');

      // Step 4: Sort levels by level_number to ensure correct sequence
      // Note: Backend orders by level_number, so we use that instead of 'order' field
      levelsData.sort((a, b) {
        final aNum = (a['level_number'] as int?) ?? 0;
        final bNum = (b['level_number'] as int?) ?? 0;
        return aNum.compareTo(bNum);
      });
      debugPrint('✅ [UNLOCK] Sorted levels by level_number');

      // CRITICAL: Defensive filter - ensure all levels belong to the correct unit
      // This prevents bugs if backend returns levels from other units
      final filteredLevels = levelsData.where((level) {
        final levelUnitId = level['unit_id'] as String?;
        return levelUnitId == unitId;
      }).toList();

      if (filteredLevels.length != levelsData.length) {
        debugPrint('⚠️ [UNLOCK] WARNING: Backend returned ${levelsData.length} levels, but only ${filteredLevels.length} match unit $unitId');
        debugPrint('   This indicates a backend data issue, but continuing with filtered list');
      }

      // Use filtered list if different, otherwise use original
      final levelsToProcess = filteredLevels.isNotEmpty ? filteredLevels : levelsData;
      debugPrint('📊 [UNLOCK] Processing ${levelsToProcess.length} levels for unit $unitId');

      // Step 5: Find current level's index in sorted list
      final currentIndex = levelsToProcess.indexWhere(
        (level) => level['id'] == currentLevelId,
      );

      if (currentIndex == -1) {
        debugPrint('❌ [UNLOCK] ERROR: Current level $currentLevelId not found in unit levels');
        debugPrint('   Available level IDs: ${levelsToProcess.map((l) => l['id']).join(", ")}');
        return;
      }

      debugPrint('✅ [UNLOCK] Found current level at index: $currentIndex (level_number: ${levelsToProcess[currentIndex]['level_number']})');

      // Step 6: Check if there's a next level
      if (currentIndex >= levelsToProcess.length - 1) {
        debugPrint('ℹ️ [UNLOCK] Current level is the last level in unit. No next level to unlock.');
        return;
      }

      // Step 7: Get next level by index
      final nextLevelData = levelsToProcess[currentIndex + 1];
      final nextLevelId = nextLevelData['id'] as String?;
      final nextLevelNumber = nextLevelData['level_number'] as int?;

      if (nextLevelId == null) {
        debugPrint('❌ [UNLOCK] ERROR: Next level has no ID');
        return;
      }

      debugPrint('🎯 [UNLOCK] Found next level: $nextLevelId (index: ${currentIndex + 1}, level_number: $nextLevelNumber)');

      // Step 8: Check current status of next level
      final currentStatus = await _repository.getLevelStatus(userId, nextLevelId);
      debugPrint('📊 [UNLOCK] Next level $nextLevelId current status: $currentStatus');

      // Step 9: Unlock if locked, active (default), or empty
      // CRITICAL FIX: Force unlock if status is 'locked', 'active' (default), or empty
      // This ensures consistency - 'active' should be converted to 'unlocked' for clarity
      if (currentStatus == 'locked' || currentStatus == 'active' || currentStatus.isEmpty) {
        await _repository.saveLevelStatus(
          userId: userId,
          levelId: nextLevelId,
          status: 'unlocked', // Use 'unlocked' for consistency with UI expectations
        );
        debugPrint('🔓 [UNLOCK] SUCCESS: Next level $nextLevelId unlocked! Status changed: $currentStatus -> unlocked');
      } else if (currentStatus == 'completed') {
        debugPrint('ℹ️ [UNLOCK] Next level $nextLevelId already completed (skipping unlock)');
      } else {
        debugPrint('ℹ️ [UNLOCK] Next level $nextLevelId already has status: $currentStatus (assuming unlocked)');
      }
    } catch (e) {
      debugPrint('❌ [UNLOCK] ERROR: Exception during unlock process: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      // Don't throw - unlocking next level is not critical for lesson completion
    }
  }

  /// Try alternative unit ID format
  /// Example: "puk_u1" -> "puk_unit_1"
  String? _tryAlternativeUnitId(String unitId) {
    final match = RegExp(r'^(.+)_u(\d+)$').firstMatch(unitId);
    if (match != null) {
      final prefix = match.group(1);
      final number = match.group(2);
      if (prefix != null && number != null) {
        return '${prefix}_unit_$number';
      }
    }
    return null;
  }

  /// Extract unit ID from level ID
  /// Examples: 
  ///   "puk_u1_l1" -> "puk_u1"
  ///   "puk_u2_l3" -> "puk_u2"
  ///   "ppgd_u1_l1" -> "ppgd_u1"
  String? _extractUnitId(String levelId) {
    debugPrint('🔍 [EXTRACT] Extracting unitId from levelId: $levelId');
    
    // Pattern: {section}_{unit}_{level} -> {section}_{unit}
    // Example: "puk_u1_l1" -> "puk_u1"
    final match = RegExp(r'^(.+_u\d+)_l\d+$').firstMatch(levelId);
    if (match != null) {
      final unitId = match.group(1);
      debugPrint('✅ [EXTRACT] Pattern matched: $unitId');
      return unitId;
    }

    // Fallback: Try to extract by splitting on underscore
    // Take first 2 parts (section_unit)
    final parts = levelId.split('_');
    if (parts.length >= 3) {
      // Format: puk_u1_l1 -> puk_u1
      final unitId = '${parts[0]}_${parts[1]}';
      debugPrint('✅ [EXTRACT] Fallback pattern matched: $unitId');
      return unitId;
    }

    debugPrint('❌ [EXTRACT] Could not extract unit ID from level ID: $levelId');
    return null;
  }

  Future<void> _submitProgressToBackend() async {
    if (questions.isEmpty || lessonId.isEmpty) return;
    
    try {
      // Calculate correct answers
      int correctAnswers = score;
      int totalQuestions = questions.length;
      
      // Extract level_id from questions
      // If lessonId is a unit_id, use the first question's level_id
      String levelId = lessonId;
      
      // Check if lessonId is a unit_id (starts with unit pattern)
      // If so, extract level_id from first question
      if (questions.isNotEmpty) {
        levelId = questions.first.levelId;
      }
      
      await _service.submitProgress(
        levelId: levelId,
        score: score,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        correctQuestionIds: correctQuestionIds, // ✅ Send list of correct question IDs
        timeSpentSeconds: 0, // TODO: Track time spent
      );
      
      debugPrint("✅ Progress submitted: Level $levelId, Score: $score/$totalQuestions");
    } catch (e) {
      debugPrint("❌ Failed to submit progress: $e");
      // Don't show error to user, progress will be lost but quiz completion is still shown
    }
  }

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