import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_path.dart';
import '../models/training_section.dart';
import '../services/training_api_service.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

/// TrainingRepository - Pure Data Layer (NO MOCK DATA)
///
/// PRODUCTION ARCHITECTURE:
/// Flutter App → TrainingRepository → TrainingApiService (Dio) → FastAPI Backend → PostgreSQL
///
/// STRICT RULES:
/// - NO mock data allowed
/// - NO fallback to empty lists
/// - All errors must propagate to controller
/// - 100% dependent on backend
class TrainingRepository {
  final TrainingApiService _apiService = TrainingApiService(
    dio: ApiDioProvider.getDio(),
  );
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
      final pathResponse = await _apiService.getLearningPath(sectionId);

      // Return units from typed response
      // ✅ FIX: Map PathUnit (from API) -> UnitModel (for UI)
      // Since schemas match, we can Convert to JSON -> Parse with UnitModel factory
      // This reuses the logic in UnitModel.fromBackendJson and LessonNode.fromBackendJson
      return pathResponse.units
          .map((pathUnit) => UnitModel.fromBackendJson(pathUnit.toJson()))
          .toList();
    } catch (e) {
      // Let error propagate to controller
      rethrow;
    }
  }

  /// Fetch all sections from backend with SWR caching
  ///
  /// SWR Pattern:
  /// 1. Return cached data immediately (if available)
  /// 2. Revalidate from API in background
  /// 3. Update cache silently
  ///
  /// Endpoint: GET /api/v1/training/sections
  /// Returns: SectionListResponse with sections sorted by order
  Future<SectionListResponse> getSections({bool forceRefresh = false}) async {
    const cacheKey = LocalCacheService.keySections;

    try {
      // ✅ SWR Step 1: Try to return cached data first (instant <500ms)
      if (!forceRefresh) {
        final cachedData = await LocalCacheService.get<dynamic>(cacheKey);
        if (cachedData != null) {
          debugPrint('📦 [SWR] Returning cached sections');

          // Parse cached JSON
          // Parse cached JSON (Handle both Map and List format)
          final dynamic parsedJson = cachedData is String
              ? jsonDecode(cachedData)
              : cachedData;

          final List<dynamic> sectionsJson =
              parsedJson is Map<String, dynamic> &&
                  parsedJson.containsKey('sections')
              ? parsedJson['sections'] as List<dynamic>
              : parsedJson as List<dynamic>;
          final sections = sectionsJson
              .map(
                (json) =>
                    TrainingSection.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          // ✅ SWR Step 2: Revalidate in background (fire & forget)
          _revalidateSectionsInBackground();

          return SectionListResponse(
            total: sections.length,
            sections: sections,
          );
        }
      }

      // ✅ SWR Step 3: No cache or force refresh - fetch from API
      debugPrint('🌐 [SWR] Fetching sections from API...');
      final response = await _apiService.getSections();

      // ✅ Cache the response for future use
      // We encode the whole response model to JSON
      await LocalCacheService.put(
        cacheKey,
        jsonEncode(response.toJson()),
        ttl: LocalCacheService.longTtl,
      );
      debugPrint('✅ [SWR] Sections cached successfully');

      return response;
    } catch (e) {
      // ✅ Offline Resilience: If API fails, try returning stale cache
      debugPrint('⚠️ [SWR] API failed, checking stale cache: $e');

      final staleCache = await LocalCacheService.get<dynamic>(cacheKey);
      if (staleCache != null) {
        debugPrint('📦 [SWR] Returning stale cache (offline mode)');
        // Parse cached JSON (Handle both Map and List format)
        final dynamic parsedJson = staleCache is String
            ? jsonDecode(staleCache)
            : staleCache;

        final List<dynamic> sectionsJson =
            parsedJson is Map<String, dynamic> &&
                parsedJson.containsKey('sections')
            ? parsedJson['sections'] as List<dynamic>
            : parsedJson as List<dynamic>;
        final sections = sectionsJson
            .map(
              (json) => TrainingSection.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return SectionListResponse(total: sections.length, sections: sections);
      }

      rethrow;
    }
  }

  /// Background revalidation for sections (fire & forget)
  void _revalidateSectionsInBackground() {
    Future(() async {
      try {
        debugPrint('🔄 [SWR] Background revalidating sections...');
        final response = await _apiService.getSections();
        await LocalCacheService.put(
          LocalCacheService.keySections,
          jsonEncode(response.toJson()),
          ttl: LocalCacheService.longTtl,
        );
        debugPrint('✅ [SWR] Background revalidation complete');
      } catch (e) {
        debugPrint('⚠️ [SWR] Background revalidation failed: $e');
      }
    });
  }

  /// Fetch learning path for a specific section with SWR caching
  ///
  /// Endpoint: GET /api/v1/training/sections/{sectionId}/path
  /// Returns: List of UnitModel for that section
  Future<List<UnitModel>> getLearningPathBySection(String sectionId) async {
    final cacheKey = '${LocalCacheService.keyUnitsPrefix}$sectionId';

    try {
      // ✅ SWR: Try cached data first
      final cachedData = await LocalCacheService.get<dynamic>(cacheKey);
      if (cachedData != null) {
        debugPrint('📦 [SWR] Returning cached units for section: $sectionId');

        final Map<String, dynamic> pathData = cachedData is String
            ? jsonDecode(cachedData) as Map<String, dynamic>
            : cachedData as Map<String, dynamic>;
        final units =
            (pathData['units'] as List<dynamic>?)
                ?.map(
                  (unitJson) => UnitModel.fromBackendJson(
                    unitJson as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [];

        // Revalidate in background
        _revalidateUnitsInBackground(sectionId);

        return units;
      }

      // No cache - fetch from API
      debugPrint('🌐 [SWR] Fetching units for section: $sectionId from API...');
      final pathResponse = await _apiService.getLearningPath(sectionId);

      // Cache the response
      await LocalCacheService.put(
        cacheKey,
        jsonEncode(pathResponse.toJson()),
        ttl: LocalCacheService.longTtl,
      );

      // ✅ FIX: Map PathUnit -> UnitModel
      return pathResponse.units
          .map((pathUnit) => UnitModel.fromBackendJson(pathUnit.toJson()))
          .toList();
    } catch (e) {
      // Offline resilience
      final staleCache = await LocalCacheService.get<dynamic>(cacheKey);
      if (staleCache != null) {
        debugPrint('📦 [SWR] Returning stale cache for section: $sectionId');
        final Map<String, dynamic> pathData = staleCache is String
            ? jsonDecode(staleCache) as Map<String, dynamic>
            : staleCache as Map<String, dynamic>;
        return (pathData['units'] as List<dynamic>?)
                ?.map(
                  (unitJson) => UnitModel.fromBackendJson(
                    unitJson as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [];
      }
      rethrow;
    }
  }

  /// Background revalidation for units
  void _revalidateUnitsInBackground(String sectionId) {
    Future(() async {
      try {
        debugPrint('🔄 [SWR] Background revalidating units for: $sectionId');
        final pathResponse = await _apiService.getLearningPath(sectionId);
        await LocalCacheService.put(
          '${LocalCacheService.keyUnitsPrefix}$sectionId',
          jsonEncode(pathResponse.toJson()),
          ttl: LocalCacheService.longTtl,
        );
        debugPrint('✅ [SWR] Units revalidation complete for: $sectionId');
      } catch (e) {
        debugPrint('⚠️ [SWR] Units revalidation failed: $e');
      }
    });
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
      final response = await _apiService.getLevelQuestions(levelId);

      if (response.questions.isEmpty) {
        throw Exception('No questions found for level "$levelId"');
      }

      return response.questions;
    } catch (e) {
      // Let error propagate to controller
      rethrow;
    }
  }

  // ===============================================================
  // 3. PROGRESS MANAGEMENT (SERVER-SIDE SOURCE OF TRUTH)
  // ===============================================================

  /// Fetch user progress from backend
  ///
  /// Returns: Map<levelId, status>
  /// Example: {"puk_u1_l1": "COMPLETED", "puk_u1_l2": "UNLOCKED"}
  /// Fetch user progress from backend
  ///
  /// If sectionId is null, fetches ALL progress (Global).
  /// Returns: Map<levelId, status>
  /// Example: {"puk_u1_l1": "COMPLETED", "puk_u1_l2": "UNLOCKED"}
  Future<Map<String, String>> fetchUserProgress(
    String userId, {
    String? sectionId,
  }) async {
    try {
      // ✅ Call API directly (No Local Cache)
      final progressMap = await _apiService.getProgressState(
        sectionId: sectionId,
      );
      debugPrint(
        '📊 [REPO] Fetched ${progressMap.length} progress entries from backend (${sectionId ?? "Global"})',
      );
      return progressMap;
    } catch (e) {
      debugPrint('⚠️ [REPO] Failed to fetch progress: $e');
      // Return empty map on failure (Network error) -> UI will handle it (or show error)
      return {};
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
    throw UnimplementedError(
      'Progress submission endpoint not implemented yet',
    );
  }
}
