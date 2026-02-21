// Training API Service
//
// Service layer for all training-related API calls.
// Uses Dio for HTTP requests and follows backend API contract exactly.
//
// IMPORTANT: All endpoints must match API_CONTRACT.md exactly.
// No data transformation or interpretation - pure pass-through.

import 'package:dio/dio.dart';
import '../models/training_section.dart';
import '../models/training_unit.dart';
import '../models/training_level.dart';
import '../models/training_question.dart';
import '../models/learning_path.dart';

import 'package:scout_os_app/core/config/environment.dart';

class TrainingApiService {
  final Dio _dio;
  final String baseUrl;

  TrainingApiService({required Dio dio, String? baseUrl})
    : _dio = dio,
      baseUrl = baseUrl ?? Environment.apiBaseUrl;

  // ==================== SECTION ENDPOINTS ====================

  /// GET /training/sections
  /// Get all active training sections
  Future<SectionListResponse> getSections() async {
    try {
      final response = await _dio.get('/training/sections');
      return SectionListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /training/sections/{section_id}
  /// Get specific section by ID
  Future<TrainingSection> getSection(String sectionId) async {
    try {
      final response = await _dio.get('/training/sections/$sectionId');
      return TrainingSection.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /training/sections/{section_id}/units
  /// Get all units in a section
  Future<UnitListResponse> getSectionUnits(String sectionId) async {
    try {
      final response = await _dio.get('/training/sections/$sectionId/units');
      return UnitListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== UNIT ENDPOINTS ====================

  /// GET /training/units/{unit_id}
  /// Get specific unit by ID
  Future<TrainingUnit> getUnit(String unitId) async {
    try {
      final response = await _dio.get('/training/units/$unitId');
      return TrainingUnit.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /training/units/{unit_id}/levels
  /// Get all levels in a unit
  Future<LevelListResponse> getUnitLevels(String unitId) async {
    try {
      final response = await _dio.get('/training/units/$unitId/levels');
      return LevelListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== LEVEL ENDPOINTS ====================

  /// GET /training/levels/{level_id}
  /// Get specific level by ID
  Future<TrainingLevel> getLevel(String levelId) async {
    try {
      final response = await _dio.get('/training/levels/$levelId');
      return TrainingLevel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /training/levels/{level_id}/questions
  /// Get all questions in a level
  Future<QuestionListResponse> getLevelQuestions(String levelId) async {
    try {
      final response = await _dio.get('/training/levels/$levelId/questions');
      final responseData = QuestionListResponse.fromJson(response.data);

      // DEFENSIVE FILTERING: Ensure we only return questions for this specific levelId
      // This prevents bugs where backend returns all questions
      final filteredQuestions = responseData.questions
          .where((q) => q.levelId == levelId)
          .toList();

      if (filteredQuestions.isEmpty && responseData.questions.isNotEmpty) {
        // Backend returned questions but none match the levelId
        throw Exception(
          'Backend returned ${responseData.questions.length} questions but none match level "$levelId"',
        );
      }

      // CRITICAL: Sort by order field to maintain exact sequence from database
      // Backend already orders by order field, but we ensure it here as well
      filteredQuestions.sort((a, b) => a.order.compareTo(b.order));

      return QuestionListResponse(
        total: filteredQuestions.length,
        levelId: levelId,
        questions: filteredQuestions,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== LEARNING PATH ENDPOINT ====================

  /// GET /training/sections/{section_id}/path
  /// Get Duolingo-style learning path for a section
  Future<LearningPathResponse> getLearningPath(String sectionId) async {
    try {
      final response = await _dio.get('/training/sections/$sectionId/path');
      return LearningPathResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PROGRESS ENDPOINTS (TODO - To Be Implemented) ====================

  /// POST /training/progress/submit
  /// Submit level completion and update user progress
  ///
  /// TODO: Implement when backend endpoint is ready
  Future<Map<String, dynamic>> submitProgress({
    required String levelId,
    required int score,
    required int totalQuestions,
    required int timeSpentSeconds,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _dio.post(
        '/training/progress/submit',
        data: {
          'level_id': levelId,
          'score': score,
          'total_questions': totalQuestions,
          'time_spent_seconds': timeSpentSeconds,
          'answers': answers,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /training/progress/state
  /// Get current user progress state.
  /// If sectionId is provided, returns progress for that section.
  /// If sectionId is null, returns progress for ALL sections (Global).
  ///
  /// Backend returns: {success: true, section_id: "...", progress: {"puk_u1_l1": "completed", ...}}
  Future<Map<String, String>> getProgressState({String? sectionId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sectionId != null) {
        queryParams['section_id'] = sectionId;
      }

      final response = await _dio.get(
        '/training/progress/state',
        queryParameters: queryParams,
      );

      // ✅ FIX: Handle Map response from Backend
      // Format: {"success": true, "section_id": "puk", "progress": {"puk_u1_l1": "completed"}}
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final Map<String, dynamic>? progressData =
          data['progress'] as Map<String, dynamic>?;

      if (progressData == null) {
        return {};
      }

      final Map<String, String> progressMap = {};

      for (var entry in progressData.entries) {
        progressMap[entry.key] = entry.value?.toString() ?? 'unknown';
      }

      return progressMap;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  Exception _handleError(DioException error) {
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['detail'] ?? 'Unknown error';

      switch (statusCode) {
        case 400:
          return Exception('Bad Request: $message');
        case 401:
          return Exception('Unauthorized: Please login again');
        case 404:
          return Exception('Not Found: $message');
        case 500:
          return Exception('Server Error: $message');
        default:
          return Exception('Error $statusCode: $message');
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet.');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('Cannot connect to server. Is backend running?');
    } else {
      return Exception('Network error: ${error.message}');
    }
  }
}
