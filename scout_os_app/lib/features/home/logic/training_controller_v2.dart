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
import '../data/services/training_api_service.dart';
import '../data/models/learning_path.dart';
import '../data/models/progress_state.dart';
import 'package:scout_os_app/core/config/environment.dart';

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
    // Initialize Dio with base configuration
    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: Environment.connectTimeout),
        receiveTimeout: Duration(milliseconds: Environment.connectTimeout),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _apiService = TrainingApiService(dio: dio);
    
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
      await Future.wait([
        fetchPath(sectionId),
        fetchProgress(),
      ]);
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
      _learningPath = await _apiService.getLearningPath(sectionId);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = _formatError(e);
      rethrow;
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
      // TODO: Uncomment when backend endpoint is ready
      // final json = await _apiService.getProgressState();
      // _progressState = ProgressStateResponse.fromJson(json);
      
      // TEMPORARY: Return empty progress (all locked) until backend ready
      _progressState = ProgressStateResponse(sections: []);
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Don't fail if progress endpoint not ready yet
      debugPrint("⚠️ Progress endpoint not available: $e");
      _progressState = ProgressStateResponse(sections: []);
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
