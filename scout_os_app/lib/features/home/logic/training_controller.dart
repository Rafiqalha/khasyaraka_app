import 'package:flutter/material.dart';
import 'package:scout_os_app/core/auth/local_auth_service.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import '../data/repositories/training_repository.dart';
import '../data/models/training_path.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';

class TrainingController extends ChangeNotifier {
  final TrainingRepository _repository = TrainingRepository();
  final LocalAuthService _authService = LocalAuthService();
  final AuthRepository _authRepo = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  bool isLoading = false;
  String? errorMessage;
  List<UnitModel> units = [];
  
  // Duolingo-style progress tracking
  int userXp = 0;
  int userStreak = 0;
  int userHearts = 5;

  TrainingController() {
    loadPathData();
  }

  Future<void> loadPathData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      units = await _repository.getLearningPath();
      await loadProgress();
      await loadUserStats();
      
      if (units.isEmpty) {
        errorMessage = "Belum ada path training yang tersedia. Hubungi administrator.";
      }
    } on Exception catch (e) {
      final errorString = e.toString();
      
      if (errorString.contains('404') || errorString.contains('not found')) {
        errorMessage = "Path training tidak ditemukan di server.";
      } else if (errorString.contains('timeout')) {
        errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
      } else if (errorString.contains('NetworkException')) {
        errorMessage = "Tidak dapat terhubung ke server. Pastikan backend berjalan.";
      } else if (errorString.contains('500')) {
        errorMessage = "Server error. Database atau Redis bermasalah.";
      } else {
        errorMessage = "Gagal memuat data path. Coba lagi nanti.";
      }
      
      debugPrint("❌ Error loading path: $e");
    } catch (e) {
      errorMessage = "Terjadi kesalahan tidak terduga.";
      debugPrint("❌ Unexpected Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadPathData();
  }

  Future<void> loadProgress() async {
    try {
      debugPrint('🔄 [LOAD_PROGRESS] START: Beginning loadProgress...');
      
      // CRITICAL FIX: Use AuthRepository to get userId from JWT (same as LessonController)
      // This ensures we always get the correct userId even if LocalAuthService is not initialized
      String? userId;
      try {
        final currentUser = await _authRepo.getCurrentUser();
        userId = currentUser.id;
        debugPrint('✅ [LOAD_PROGRESS] Got userId from JWT: $userId');
      } catch (e) {
        debugPrint('⚠️ [LOAD_PROGRESS] Failed to get userId from JWT: $e');
        // Fallback to LocalAuthService
        await _authService.init();
        userId = await _authService.getCurrentUserId();
        if (userId != null) {
          debugPrint('✅ [LOAD_PROGRESS] Got userId from LocalAuthService: $userId');
        }
      }
      
      if (userId == null || userId.isEmpty) {
        debugPrint('⚠️ [LOAD_PROGRESS] No userId found, but Level 1 will still be unlocked');
        // CRITICAL: Even without userId, Level 1 should be unlocked
        // Use _lockAllLessons which already unlocks Level 1
        units = units.map(_lockAllLessons).toList();
        notifyListeners();
        return;
      }

      // userId is guaranteed non-null here (checked above)
      final nonNullUserId = userId;
      
      debugPrint('🔄 [LOAD_PROGRESS] Loading progress for userId: $nonNullUserId');

      // CRITICAL: Add small delay to ensure SharedPreferences writes are complete
      await Future.delayed(Duration(milliseconds: 100));

      // CRITICAL: Always fetch fresh progress from repository using CURRENT userId
      // This prevents User B from seeing User A's progress
      final progressMap = await _repository.getProgressMap(nonNullUserId);
      
      debugPrint('📊 [LOAD_PROGRESS] Progress map size: ${progressMap.length}');
      if (progressMap.isNotEmpty) {
        debugPrint('📋 [LOAD_PROGRESS] Progress entries:');
        progressMap.forEach((levelId, status) {
          debugPrint('   - $levelId: $status');
        });
      }
      
      if (progressMap.isEmpty) {
        debugPrint('⚠️ [LOAD_PROGRESS] No progress found, auto-unlocking Level 1 for all units...');
        
        // FEATURE: AUTO-UNLOCK LEVEL 1 FOR ALL UNITS (when no progress exists)
        // Even if there's no progress, Level 1 should be unlocked
        units = units.map((unit) {
          final updatedLessons = unit.lessons.map((lesson) {
            final levelId = lesson.levelId ?? lesson.id.toString();
            
            // Auto-unlock Level 1
            if (lesson.orderIndex == 1) {
              debugPrint('🆕 [AUTO_UNLOCK] Auto-unlocking Level 1: $levelId (no progress exists)');
              
              // Persist unlock to database (userId is guaranteed non-null here)
              _repository.saveLevelStatus(
                userId: nonNullUserId,
                levelId: levelId,
                status: 'unlocked',
              ).catchError((e) {
                debugPrint('⚠️ [AUTO_UNLOCK] Failed to save unlock status for $levelId: $e');
              });
              
              return LessonNode(
                id: lesson.id,
                pathId: lesson.pathId,
                title: lesson.title,
                description: lesson.description,
                iconName: lesson.iconName,
                status: 'unlocked', // Level 1 is unlocked
                stars: lesson.stars,
                orderIndex: lesson.orderIndex,
                levelId: lesson.levelId,
              );
            }
            
            // Other levels remain locked
            return LessonNode(
              id: lesson.id,
              pathId: lesson.pathId,
              title: lesson.title,
              description: lesson.description,
              iconName: lesson.iconName,
              status: 'locked',
              stars: lesson.stars,
              orderIndex: lesson.orderIndex,
              levelId: lesson.levelId,
            );
          }).toList();
          return UnitModel(
            id: unit.id,
            unitId: unit.unitId,
            title: unit.title,
            description: unit.description,
            colorHex: unit.colorHex,
            orderIndex: unit.orderIndex,
            lessons: updatedLessons,
          );
        }).toList();
        
        notifyListeners();
        return;
      }

      debugPrint('🔄 [LOAD_PROGRESS] Updating units with progress data...');
      
      // CRITICAL: Create new list instances to ensure widget rebuild
      final updatedUnits = units.map((unit) {
        final updatedLessons = unit.lessons.map((lesson) {
          final levelId = lesson.levelId ?? lesson.id.toString();
          String? status = progressMap[levelId];
          
          // FEATURE: AUTO-UNLOCK LEVEL 1 FOR ALL UNITS
          // Level 1 (orderIndex == 1) must always be unlocked by default
          if (lesson.orderIndex == 1) {
            if (status == null || status == 'locked' || status.isEmpty) {
              debugPrint('🆕 [AUTO_UNLOCK] Auto-unlocking Level 1: $levelId (orderIndex: ${lesson.orderIndex})');
              status = 'unlocked';
              
              // CRITICAL: Persist this unlock to database immediately
              // Fire and forget - don't await to avoid blocking UI
              _repository.saveLevelStatus(
                userId: nonNullUserId,
                levelId: levelId,
                status: 'unlocked',
              ).catchError((e) {
                debugPrint('⚠️ [AUTO_UNLOCK] Failed to save unlock status for $levelId: $e');
              });
            } else {
              debugPrint('✅ [AUTO_UNLOCK] Level 1 $levelId already has status: $status');
            }
          }
          
          // Debug logging for each lesson
          if (status != null) {
            debugPrint('✅ [LOAD_PROGRESS] Level $levelId: $status');
          } else {
            debugPrint('🔒 [LOAD_PROGRESS] Level $levelId: not in progress map (will use default: locked)');
          }
          
          // CRITICAL: Always create new LessonNode instance, even if status is null
          // This ensures widget rebuild detects the change
          return LessonNode(
            id: lesson.id,
            pathId: lesson.pathId,
            title: lesson.title,
            description: lesson.description,
            iconName: lesson.iconName,
            status: status ?? 'locked', // Use 'locked' as default instead of null
            stars: lesson.stars,
            orderIndex: lesson.orderIndex,
            levelId: lesson.levelId,
          );
        }).toList();
        return UnitModel(
          id: unit.id,
          unitId: unit.unitId,
          title: unit.title,
          description: unit.description,
          colorHex: unit.colorHex,
          orderIndex: unit.orderIndex,
          lessons: updatedLessons,
        );
      }).toList();
      
      // CRITICAL: Assign new list to trigger change detection
      units = updatedUnits;
      
      debugPrint('✅ [LOAD_PROGRESS] Progress loaded successfully. Units count: ${units.length}');
      debugPrint('📊 [LOAD_PROGRESS] Notifying listeners to rebuild UI...');
      
      // CRITICAL: Force notify listeners to trigger UI rebuild
      notifyListeners();
      
      debugPrint('✅ [LOAD_PROGRESS] Listeners notified. END loadProgress.');
      
      // ✅ CRITICAL: Refresh user stats after loading progress
      // XP is managed by backend only - no client-side calculation
      // This ensures XP and Streak are updated in the header UI
      try {
        await loadUserStats();
        debugPrint('✅ [LOAD_PROGRESS] User stats refreshed: XP=$userXp, Streak=$userStreak');
      } catch (e) {
        debugPrint('⚠️ [LOAD_PROGRESS] Error refreshing user stats: $e');
        // Don't throw - stats refresh is not critical
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOAD_PROGRESS] ERROR: $e');
      debugPrint('   Stack trace: $stackTrace');
      rethrow; // Re-throw to let caller handle
    }
  }

  // ✅ REMOVED: _syncXpWithCompletedLevels()
  // XP must ONLY come from backend response, NOT calculated client-side

  Future<void> loadUserStats() async {
    debugPrint('🔄 [LOAD_STATS] Starting loadUserStats from API...');
    
    try {
      // CRITICAL: Fetch stats from remote API (not local storage)
      final remoteStats = await _profileRepo.getUserStats();
      
      userXp = remoteStats.totalXp;
      userStreak = remoteStats.streak;
      
      debugPrint('📊 [LOAD_STATS] Updated stats from API: XP=$userXp, Streak=$userStreak');
      debugPrint('📊 [LOAD_STATS] Notifying listeners to update UI header...');
      
      notifyListeners();
      
      debugPrint('✅ [LOAD_STATS] Stats loaded successfully from API');
    } catch (e) {
      debugPrint('❌ [LOAD_STATS] Error loading stats from API: $e');
      // Don't throw - set to 0 as fallback
      userXp = 0;
      userStreak = 0;
      notifyListeners();
    }
  }

  void startLesson(int lessonId) {
    // TODO: Navigate to lesson page
    // This will be handled by the UI layer
  }

  // ✅ REMOVED: completeLesson() - Manual XP accumulation
  // XP must ONLY come from backend response via loadUserStats()
  
  /// Refresh stats from API (XP comes from backend only)
  Future<void> refreshStats() async {
    await loadUserStats();
  }

  Future<void> completeLevel({
    required String levelId,
    int xpEarned = 0,
  }) async {
    // CRITICAL FIX: Use AuthRepository to get userId from JWT
    String? userId;
    try {
      final currentUser = await _authRepo.getCurrentUser();
      userId = currentUser.id;
    } catch (e) {
      // Fallback to LocalAuthService
      await _authService.init();
      userId = await _authService.getCurrentUserId();
    }
    
    if (userId == null) return;
    
    await _repository.saveLevelStatus(
      userId: userId,
      levelId: levelId,
      status: 'completed',
    );
    // ✅ REMOVED: completeLesson() - XP comes from backend response only
    // Refresh stats from API after completing level
    await loadUserStats();
  }

  /// Clear all state for logout - CRITICAL for preventing data leak between users
  /// This ensures User B doesn't see User A's unlocked levels
  void clearState() {
    debugPrint('🧹 TrainingController.clearState() - Clearing all user data');
    
    // Reset all state to default values
    units = [];
    userXp = 0;
    userStreak = 0;
    userHearts = 5;
    errorMessage = null;
    isLoading = false;
    
    // Force notify listeners to update UI
    notifyListeners();
    
    debugPrint('✅ TrainingController state cleared');
  }

  void clearForLogout() {
    // Legacy method - redirect to clearState for consistency
    clearState();
  }

  UnitModel _lockAllLessons(UnitModel unit) {
    if (unit.lessons.isEmpty) return unit;
    final minOrder = unit.lessons.map((e) => e.orderIndex).reduce((a, b) => a < b ? a : b);
    final updatedLessons = unit.lessons
        .map((lesson) {
          final isLevel1 = lesson.orderIndex == minOrder;
          // FEATURE: Level 1 should always be unlocked, even when locking all lessons
          return LessonNode(
            id: lesson.id,
            pathId: lesson.pathId,
            title: lesson.title,
            description: lesson.description,
            iconName: lesson.iconName,
            status: isLevel1 ? 'unlocked' : 'locked', // Level 1 is always unlocked
            stars: lesson.stars,
            orderIndex: lesson.orderIndex,
            levelId: lesson.levelId,
          );
        })
        .toList();
    return UnitModel(
      id: unit.id,
      unitId: unit.unitId,
      title: unit.title,
      description: unit.description,
      colorHex: unit.colorHex,
      orderIndex: unit.orderIndex,
      lessons: updatedLessons,
    );
  }

  // ✅ REMOVED: _persistUserStats() - Stats are managed by backend only
  // Use loadUserStats() to refresh stats from API
}