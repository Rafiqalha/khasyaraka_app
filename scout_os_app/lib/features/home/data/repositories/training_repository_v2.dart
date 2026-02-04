// TrainingRepository V2 - Pure Pass-Through Layer
//
// PR 1: Data Flow Stabilization
//
// CRITICAL RULES:
// 1. NO business logic
// 2. NO data transformation
// 3. NO status computation
// 4. Only: call API → return model
//
// This is a pure pass-through layer between Controller and API Service.

import '../services/training_api_service.dart';
import '../models/learning_path.dart';
import '../models/progress_state.dart';
import '../models/training_question.dart';

class TrainingRepositoryV2 {
  final TrainingApiService _apiService;

  TrainingRepositoryV2(this._apiService);

  // ==================== LEARNING PATH ====================

  /// Get learning path for a section
  /// 
  /// Pure pass-through: API → Model
  Future<LearningPathResponse> getLearningPath(String sectionId) async {
    return await _apiService.getLearningPath(sectionId);
  }

  // ==================== QUESTIONS ====================

  /// Get questions for a level
  /// 
  /// Pure pass-through: API → Model
  Future<QuestionListResponse> getLevelQuestions(String levelId) async {
    return await _apiService.getLevelQuestions(levelId);
  }

  // ==================== PROGRESS ====================

  /// Get progress state
  /// 
  /// Pure pass-through: API → Model
  /// 
  /// TODO: Uncomment when backend endpoint is ready
  Future<ProgressStateResponse> getProgressState() async {
    // TODO: Implement when backend ready
    // final json = await _apiService.getProgressState();
    // return ProgressStateResponse.fromJson(json);
    
    // TEMPORARY: Return empty progress
    return ProgressStateResponse(sections: []);
  }

  /// Submit progress
  /// 
  /// Pure pass-through: Data → API
  /// 
  /// TODO: Implement when backend endpoint is ready
  Future<Map<String, dynamic>> submitProgress({
    required String levelId,
    required int score,
    required int totalQuestions,
    required int timeSpentSeconds,
    required List<Map<String, dynamic>> answers,
  }) async {
    return await _apiService.submitProgress(
      levelId: levelId,
      score: score,
      totalQuestions: totalQuestions,
      timeSpentSeconds: timeSpentSeconds,
      answers: answers,
    );
  }
}
