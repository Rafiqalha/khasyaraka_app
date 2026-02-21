// TrainingController V2 - Backend-Driven Architecture
//
// PR 1: Data Flow Stabilization
//
// CRITICAL RULES:
// 1. NO mock data
// 2. NO unlock computation
// 3. NO local state transformation
// 4. All state comes from backend API
//
// State Management: Provider (ChangeNotifier)

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import '../data/services/training_api_service.dart';
import '../data/models/learning_path.dart';
import '../data/models/progress_state.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart'; // ✅ Added Cache Service

class TrainingControllerV2 extends ChangeNotifier {
  // ==================== DEPENDENCIES ====================
  late final TrainingApiService _apiService;

  // ==================== STATE ====================
  bool isLoading = false;
  String? errorMessage;

  // Backend-driven data (NO mock, NO computation)
  LearningPathResponse? _learningPath;
  ProgressStateResponse? _progressState;

  // ==================== GETTERS ====================
  LearningPathResponse? get learningPath => _learningPath;
  ProgressStateResponse? get progressState => _progressState;

  /// Get all sections from learning path
  List<PathUnit> get units => _learningPath?.units ?? [];

  /// Check if section is unlocked (from backend)
  bool isSectionUnlocked(String sectionId) {
    final section = _progressState?.sections.firstWhere(
      (s) => s.sectionId == sectionId,
      orElse: () => SectionProgressState(
        sectionId: sectionId,
        isUnlocked: false,
        units: [],
      ),
    );
    return section?.isUnlocked ?? false;
  }

  /// Get level status (from backend, NO computation)
  String getLevelStatus(String levelId) {
    final levelProgress = _progressState?.getLevelProgress(levelId);
    return levelProgress?.status ?? 'locked';
  }

  // ==================== CONSTRUCTOR ====================
  TrainingControllerV2() {
    // Initialize API Service with centralized Dio provider (handles JWT)
    _apiService = TrainingApiService(dio: ApiDioProvider.getDio());

    // Load initial data
    loadInitialData();
  }

  // ==================== DATA LOADING ====================

  /// Load initial data (path + progress)
  Future<void> loadInitialData({String sectionId = 'puk'}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Load both path and progress in parallel
      await Future.wait([fetchPath(sectionId), fetchProgress()]);
    } catch (e) {
      errorMessage = _formatError(e);
      debugPrint("❌ Error loading initial data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch learning path from backend
  ///
  /// Endpoint: GET /training/sections/{sectionId}/path
  ///
  /// CRITICAL: This is the ONLY source of path data.
  /// NO local computation or transformation.
  Future<void> fetchPath(String sectionId) async {
    try {
      // ✅ 1. CACHE FIRST (Instant Load)
      final cachedJson = await LocalCacheService.get(
        'learning_path_$sectionId',
      );
      if (cachedJson != null) {
        final cachedPath = LearningPathResponse.fromJson(cachedJson);
        _applySorting(cachedPath); // ✅ SORTING WAJIB
        _learningPath = cachedPath;
        notifyListeners(); // Update UI immediately with cache
      }

      // ✅ 2. NETWORK FETCH (Background Revalidation)
      final apiPath = await _apiService.getLearningPath(sectionId);

      // ✅ 3. SORTING WAJIB (Ascending)
      _applySorting(apiPath);

      // ✅ 4. UPDATE CACHE & STATE
      // Only notify if data changed or was null
      _learningPath = apiPath;
      await LocalCacheService.put(
        'learning_path_$sectionId',
        apiPath.toJson(),
      ); // Need toJson()

      errorMessage = null;
      notifyListeners(); // Rebuild UI with fresh data
    } catch (e) {
      errorMessage = _formatError(e);
      // If network fails but we have cache, don't throw, just show cache
      if (_learningPath == null) rethrow;
    }
  }

  // ✅ HELPER: Sorting Logic
  void _applySorting(LearningPathResponse path) {
    // 1. Sort Units by Order
    path.units.sort((a, b) => a.order.compareTo(b.order));

    // 2. Sort Levels within Units by LevelNumber
    for (var unit in path.units) {
      unit.levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
    }
  }

  /// Fetch progress state from backend
  ///
  /// Endpoint: GET /training/progress/state
  ///
  /// CRITICAL: This is the ONLY source of progress/unlock state.
  /// NO local computation.
  Future<void> fetchProgress() async {
    try {
      // ✅ 1. CACHE FIRST
      final sectionId =
          _learningPath?.sectionId ?? 'puk'; // Default to loaded section
      final cacheKey = 'progress_$sectionId';

      final cachedJson = await LocalCacheService.get(cacheKey);
      if (cachedJson != null) {
        _progressState = ProgressStateResponse.fromJson(cachedJson);
        notifyListeners();
      }

      // ✅ 2. NETWORK FETCH
      final json = await _apiService.getProgressState();

      // ✅ 3. UPDATE CACHE & STATE
      _progressState = ProgressStateResponse.fromJson(json);
      await LocalCacheService.put(cacheKey, json);

      errorMessage = null;
      notifyListeners(); // ✅ Update UI Realtime
    } catch (e) {
      // Don't fail if progress endpoint not ready yet
      debugPrint("⚠️ Progress endpoint not available: $e");
      // Keep cached state if available
      if (_progressState == null) {
        _progressState = ProgressStateResponse(sections: []);
      }
    }
  }

  /// Refresh all data
  Future<void> refresh({String sectionId = 'puk'}) async {
    await loadInitialData(sectionId: sectionId);
  }

  // ==================== ERROR HANDLING ====================

  String _formatError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('404') || errorString.contains('not found')) {
      return "Path training tidak ditemukan di server.";
    } else if (errorString.contains('timeout')) {
      return "Koneksi timeout. Periksa koneksi internet Anda.";
    } else if (errorString.contains('NetworkException') ||
        errorString.contains('connection')) {
      return "Tidak dapat terhubung ke server. Pastikan backend berjalan.";
    } else if (errorString.contains('500')) {
      return "Server error. Database atau Redis bermasalah.";
    } else {
      return "Gagal memuat data path. Coba lagi nanti.";
    }
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    // Cleanup if needed
    super.dispose();
  }
}
