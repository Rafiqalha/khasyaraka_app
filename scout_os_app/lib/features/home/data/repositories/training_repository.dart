import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_path.dart';
import '../datasources/training_service.dart';

/// TrainingRepository - Pure Data Layer (NO MOCK DATA)
/// 
/// PRODUCTION ARCHITECTURE:
/// Flutter App → TrainingRepository → TrainingService (HTTP) → FastAPI Backend → PostgreSQL
/// 
/// STRICT RULES:
/// - NO mock data allowed
/// - NO fallback to empty lists
/// - All errors must propagate to controller
/// - 100% dependent on backend
class TrainingRepository {
  final TrainingService _apiService = TrainingService();
  static const String _progressKeyPrefix = 'training_progress_';

  // ===============================================================
  // 1. GET LEARNING PATH DATA (REAL API ONLY)
  // ===============================================================
  
  /// Fetch learning path from backend
  /// 
  /// Endpoint: GET /api/v1/training/sections/{sectionId}/path
  /// 
  /// Returns: List of UnitModel with lessons
  /// Throws: Exception if API fails (404, timeout, etc.)
  Future<List<UnitModel>> getLearningPath({String sectionId = 'puk'}) async {
    try {
      // Call real backend API
      final pathData = await _apiService.fetchLearningPath(sectionId);
      
      // Parse response to UnitModel
      final units = (pathData['units'] as List<dynamic>?)
          ?.map((unitJson) => UnitModel.fromBackendJson(unitJson as Map<String, dynamic>))
          .toList() ?? [];
      
      if (units.isEmpty) {
        throw Exception('No units found in section "$sectionId"');
      }
      
      return units;
    } catch (e) {
      // Let error propagate to controller
      rethrow;
    }
  }

  // ===============================================================
  // 2. GET QUIZ QUESTIONS (REAL API ONLY)
  // ===============================================================
  
  /// Fetch questions for a specific level
  /// 
  /// Endpoint: GET /api/v1/training/levels/{levelId}/questions
  /// 
  /// Parameters:
  /// - levelId: String (e.g., "puk_u1_l1")
  /// 
  /// Returns: List of TrainingQuestion
  /// Throws: Exception if API fails
  Future<List<dynamic>> getQuestionsByLevel(String levelId) async {
    try {
      // Call real backend API
      final questions = await _apiService.fetchQuestions(levelId);
      
      if (questions.isEmpty) {
        throw Exception('No questions found for level "$levelId"');
      }
      
      return questions;
    } catch (e) {
      // Let error propagate to controller
      rethrow;
    }
  }

  // ===============================================================
  // 3. LOCAL PROGRESS STORAGE (PER USER)
  // ===============================================================

  Future<Map<String, String>> getProgressMap(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_progressKeyPrefix$userId');
    if (raw == null || raw.isEmpty) {
      debugPrint('📊 [REPO] No progress found for userId: $userId (key: $_progressKeyPrefix$userId)');
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final progressMap = decoded.map((key, value) => MapEntry(key, value.toString()));
    debugPrint('📊 [REPO] Loaded progress for userId: $userId (${progressMap.length} entries)');
    return progressMap;
  }

  Future<String> getLevelStatus(String userId, String levelId) async {
    final progress = await getProgressMap(userId);
    final status = progress[levelId] ?? 'locked';
    debugPrint('📊 [REPO] Level $levelId status for userId $userId: $status');
    return status;
  }

  Future<void> saveLevelStatus({
    required String userId,
    required String levelId,
    required String status,
  }) async {
    debugPrint('💾 [REPO] Saving level status: userId=$userId, levelId=$levelId, status=$status');
    
    final prefs = await SharedPreferences.getInstance();
    final progress = await getProgressMap(userId);
    progress[levelId] = status;
    
    final key = '$_progressKeyPrefix$userId';
    await prefs.setString(key, jsonEncode(progress));
    
    // Verify save
    final saved = prefs.getString(key);
    if (saved != null) {
      final verify = jsonDecode(saved) as Map<String, dynamic>;
      debugPrint('✅ [REPO] Saved successfully. Progress map now has ${verify.length} entries');
      debugPrint('   Verified: $levelId = ${verify[levelId]}');
    } else {
      debugPrint('❌ [REPO] ERROR: Failed to save progress!');
    }
  }

  // ===============================================================
  // 3. COMPLETE LESSON & UNLOCK NEXT (FUTURE IMPLEMENTATION)
  // ===============================================================
  
  /// Submit lesson completion to backend
  /// 
  /// Endpoint: POST /api/v1/training/progress/complete
  /// 
  /// Parameters:
  /// - levelId: String (e.g., "puk_u1_l1")
  /// - score: int
  /// - xpEarned: int
  /// 
  /// TODO: Implement when backend endpoint is ready
  Future<void> completeLessonAndUnlockNext({
    required String levelId,
    required int score,
    required int xpEarned,
  }) async {
    // TODO: Implement POST request to backend
    // await _apiService.submitLessonCompletion(levelId, score, xpEarned);
    throw UnimplementedError('Progress submission endpoint not implemented yet');
  }
}
