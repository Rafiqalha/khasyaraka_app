import 'package:flutter/material.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import '../data/repositories/training_repository.dart';
import '../data/models/training_path.dart';
import '../data/models/training_section.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import '../data/services/training_api_service.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class TrainingController extends ChangeNotifier {
  // ✅ Fixed duplicate method definition
  final TrainingRepository _repository = TrainingRepository();
  final AuthRepository _authRepo = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  bool isLoading = false;
  bool _isPathLoading = false; // ✅ Deduplication lock
  String? errorMessage;
  List<UnitModel> units = [];
  List<SectionWithUnits> sectionsWithUnits = []; // Backend-driven sections
  
  // Duolingo-style progress tracking
  int userXp = 0;
  int userStreak = 0;
  int userHearts = 5;  // Default hearts (lives)

  TrainingController() {
    loadPathData();
  }

  /// ✅ NEW: Load ONLY units and sections (Structure Only)
  /// efficiently without waiting for progress or stats
  Future<void> loadUnitsOnly() async {
    // ✅ Deduplication guard
    if (_isPathLoading) {
      debugPrint('⏭️ [LOAD_UNITS] Skipping duplicate loadUnitsOnly call');
      return;
    }
    _isPathLoading = true;
    
    // Only set global isLoading if sections are empty (first load)
    if (sectionsWithUnits.isEmpty) {
      isLoading = true;
      notifyListeners();
    }
    
    errorMessage = null;

    try {
      debugPrint('🔄 [LOAD_UNITS] Fetching sections from backend...');
      
      // Fetch sections with backend order
      // TODO: Add caching for sections list itself if needed
      final sectionsResponse = await _repository.getSections();
      var sections = sectionsResponse.sections;
      
      // DEDUPLICATE sections by ID (Safety check)
      final seenIds = <String>{};
      sections = sections.where((s) => seenIds.add(s.id)).toList();
      
      // Sort by backend order field
      sections.sort((a, b) => a.order.compareTo(b.order));
      
      debugPrint('📚 [LOAD_UNITS] Fetched ${sections.length} sections');
      
      // Initialize sectionsWithUnits with empty units (Lazy Loading)
      sectionsWithUnits = sections.map((s) => SectionWithUnits(
        section: s,
        units: [],
      )).toList();
      
      // Check if we have cached units to populate immediately (Hybrid Strategy)
      // This keeps the "Fast Startup" but restores state if available
      final cachedUnitsJson = await LocalCacheService.get('units_cache');
      if (cachedUnitsJson != null) {
          try {
            final cachedUnits = (cachedUnitsJson as List)
                .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
                .toList();

            // Distribute cached units to sections
            for (var i = 0; i < sectionsWithUnits.length; i++) {
              final sectionId = sectionsWithUnits[i].section.id;
              final sectionUnits = cachedUnits.where((u) => u.sectionId == sectionId).toList();
              
              if (sectionUnits.isNotEmpty) {
                 sectionsWithUnits[i] = SectionWithUnits(
                   section: sectionsWithUnits[i].section,
                   units: sectionUnits,
                 );
              }
            }

            // Rebuild flattened units from the segregated sections (Ensures correct order)
            _rebuildFlattenedUnits();
            debugPrint('📦 [LOAD_UNITS] Restored units from cache');
          } catch(e) {
            debugPrint('⚠️ [LOAD_UNITS] Cache parse failed: $e');
            units = [];
          }
      } else {
        units = [];
      }

      // ✅ FALLBACK: If cache is empty/failed/missing, fetch from API immediately
      if (units.isEmpty) {
        debugPrint('🌐 [LOAD_UNITS] Cache miss. Fetching units for all ${sectionsWithUnits.length} sections...');
        
        // Fetch all sections in parallel
        await Future.wait(sectionsWithUnits.map((s) async {
          try {
            final fetchedUnits = await _repository.getLearningPathBySection(s.section.id);
            
            // Find and update the section in our list
            final index = sectionsWithUnits.indexWhere((item) => item.section.id == s.section.id);
            if (index != -1) {
              sectionsWithUnits[index] = SectionWithUnits(
                section: s.section,
                units: fetchedUnits,
              );
            }
          } catch (e) {
            debugPrint('⚠️ [LOAD_UNITS] Failed to fetch units for ${s.section.id}: $e');
          }
        }));
        
        // Rebuild flattened list from the updated sections
        _rebuildFlattenedUnits();
         
        // Cache the fresh result
        if (units.isNotEmpty) {
           await LocalCacheService.put('units_cache', units.map((e) => e.toJson()).toList());
           debugPrint('✅ [LOAD_UNITS] Fetched and cached ${units.length} total units');
        }
      }
      
      if (sectionsWithUnits.isEmpty) {
        errorMessage = "Belum ada path training yang tersedia.";
      }
      
    } on Exception catch (e) {
      final errorString = e.toString();
      if (errorString.contains('404')) {
        errorMessage = "Path training tidak ditemukan.";
      } else if (errorString.contains('timeout')) {
        errorMessage = "Koneksi timeout.";
      } else if (errorString.contains('NetworkException')) {
        errorMessage = "Tidak dapat terhubung ke server.";
      } else {
        errorMessage = "Gagal memuat data path.";
      }
      debugPrint("❌ Error loading sections: $e");
    } catch (e) {
      errorMessage = "Terjadi kesalahan tidak terduga.";
      debugPrint("❌ Unexpected Error: $e");
    } finally {
      isLoading = false;
      _isPathLoading = false;
      notifyListeners();
    }
  }

  /// Lazy Load Units for a specific Section
  Future<void> loadSectionUnits(String sectionId) async {
    debugPrint('🔄 [LAZY_LOAD] Loading units for section: $sectionId');
    
    try {
      final sectionIndex = sectionsWithUnits.indexWhere((s) => s.section.id == sectionId);
      if (sectionIndex == -1) return;

      // Ensure we don't overwrite if already loaded? 
      // User might want to refresh. So we fetch simple.
      
      final sectionUnits = await _repository.getLearningPathBySection(sectionId);
      
      // Sort units
      sectionUnits.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      
      // Update specific section
      sectionsWithUnits[sectionIndex] = SectionWithUnits(
        section: sectionsWithUnits[sectionIndex].section,
        units: sectionUnits,
      );
      
      // Rebuild flattened units list
      _rebuildFlattenedUnits();
      
      // Save to cache
      await LocalCacheService.put('units_cache', units.map((e) => e.toJson()).toList());
      
      notifyListeners();
      debugPrint('✅ [LAZY_LOAD] Loaded ${sectionUnits.length} units for section $sectionId');
      
      // Also refresh progress for this section specially?
      // Or rely on global progress?
      // Since we just loaded NEW units, they might not have progress applied if global progress only mapped to old units.
      // But _updateUnitsWithProgress updates 'units' list. 
      // Since we rebuilt 'units', we need to re-apply progress if we have it stored?
      // Or just fetch progress again for this section?
      _reapplyProgress();
      
    } catch (e) {
      debugPrint('❌ [LAZY_LOAD] Failed: $e');
      // Ideally show snackbar or error in UI
    }
  }


  
  // Re-fetch progress to ensure new units are updated
  // Optimization: Could store progressMap in variable to re-apply without fetch
  Future<void> _reapplyProgress() async {
     await loadProgress();
  }

  /// Backward compatible Method equivalent to old behavior
  /// Loads Units AND Progress AND Stats (Sequential or Parallel)
  Future<void> loadPathData() async {
    // 1. Load Units (Structure)
    await loadUnitsOnly();
    
    // 2. Load User Data (Parallel)
    await Future.wait([
      loadProgress(),
      loadUserStats(),
    ]);
  }

  Future<void> refresh() async {
    await loadPathData();
  }

  // ✅ HELPER: Strict Sorting
  void _sortUnitsAndLessons() {
    // 1. Sort Units within Sections (Done in _rebuildFlattenedUnits)
    // CRITICAL: component state relies on `units` matching the visual order (Section 1 -> Section 2)
    // DO NOT sort `units` globally by orderIndex only, as it interleaves sections!
    
    // 2. Sort Lessons within Units
    for (var unit in units) {
      unit.lessons.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }
  }

  void _rebuildFlattenedUnits() {
    units = [];
    for (var section in sectionsWithUnits) {
       // Ensure units in this section are sorted
       section.units.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
       
       units.addAll(section.units);
    }
    _sortUnitsAndLessons();
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
        // Google login only - no local fallback
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

      // ✅ 1. SERVER-SIDE SOURCE OF TRUTH (No Local Cache)
      // We skip local storage entirely to ensure fresh data.
      // Loading state is handled by the UI.

      // ✅ 2. NETWORK FETCH (Primary Source)
      // Fetch progress from backend (Redis-backed <50ms response)
      Map<String, String> progressMap = {};
      
      try {
        debugPrint('📡 [LOAD_PROGRESS] Fetching GLOBAL progress from backend...');
        
        // Single Batch Request (Global)
        progressMap = await _repository.fetchUserProgress(nonNullUserId, sectionId: null);
          
        debugPrint('✅ [LOAD_PROGRESS] Backend returned ${progressMap.length} progress entries total');
      } catch (e) {
        debugPrint('⚠️ [LOAD_PROGRESS] Backend fetch failed: $e');
        // If network fails, we show error or empty state (strict mode)
        errorMessage = "Gagal memuat progress. Periksa koneksi internet.";
      }
      
      // ✅ 3. ALWAYS UPDATE STATE (Handles empty case by auto-unlocking L1)
      // Even if progressMap is empty, _updateUnitsWithProgress handles auto-unlocking Level 1
      _updateUnitsWithProgress(progressMap, nonNullUserId);
      
      debugPrint('📊 [LOAD_PROGRESS] Notifying listeners with FRESH data...');
      notifyListeners();
      
      debugPrint('✅ [LOAD_PROGRESS] Listeners notified. END loadProgress.');
      
      // ✅ CRITICAL: Refresh user stats after loading progress
      try {
        await loadUserStats();
        debugPrint('✅ [LOAD_PROGRESS] User stats refreshed: XP=$userXp, Streak=$userStreak');
      } catch (e) {
        debugPrint('⚠️ [LOAD_PROGRESS] Error refreshing user stats: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOAD_PROGRESS] ERROR: $e');
      debugPrint('   Stack trace: $stackTrace');
      rethrow; // Re-throw to let caller handle
    }
  }

  // ✅ HELPER: Update units with progress map
  void _updateUnitsWithProgress(Map<String, dynamic> progressMap, String userId) {
    debugPrint('🔄 [LOAD_PROGRESS] Updating units with progress data...');
    
    // CRITICAL: Create new list instances to ensure widget rebuild
    final updatedUnits = units.map((unit) {
      final updatedLessons = unit.lessons.map((lesson) {
        final levelId = lesson.levelId ?? lesson.id.toString();
        // Get status from backend (UPPERCASE)
        String? status = progressMap[levelId]?.toString().toUpperCase();
        
        // ✅ STRICT LINEAR: Trust backend 100%
        // Backend determines which level is UNLOCKED (only ONE at a time)
        // If no status from backend → level is LOCKED
        final finalStatus = status ?? 'LOCKED';
        
        return LessonNode(
          id: lesson.id,
          pathId: lesson.pathId,
          title: lesson.title,
          description: lesson.description,
          iconName: lesson.iconName,
          status: finalStatus,
          stars: lesson.stars,
          orderIndex: lesson.orderIndex,
          levelId: lesson.levelId,
        );
      }).toList();
      return UnitModel(
        id: unit.id,
        unitId: unit.unitId,
        sectionId: unit.sectionId,
        title: unit.title,
        description: unit.description,
        colorHex: unit.colorHex,
        orderIndex: unit.orderIndex,
        lessons: updatedLessons,
      );
    }).toList();
    
    // CRITICAL: Assign new list to trigger change detection
    units = updatedUnits;
    _sortUnitsAndLessons(); // Ensure sorting is maintained
    notifyListeners();
  }

  /// Optimistically unlock next level locally without waiting for backend
  /// This ensures UI updates INSTANTLY when returning from lesson
  void unlockNextLevelLocally(String completedLevelId) {
    debugPrint('🚀 [OPTIMISTIC] Unlocking next level locally for $completedLevelId');
    
    // 1. Find the completed level and mark as COMPLETED
    bool found = false;
    int completedUnitIndex = -1;
    int completedLessonIndex = -1;
    
    // Create deep copy to modify
    List<UnitModel> newUnits = List.from(units);
    
    for (int i = 0; i < newUnits.length; i++) {
      final unit = newUnits[i];
      for (int j = 0; j < unit.lessons.length; j++) {
        if (unit.lessons[j].levelId == completedLevelId) {
          // Found it! Mark COMPLETED
          List<LessonNode> newLessons = List.from(unit.lessons);
          newLessons[j] = _copyLessonWithStatus(unit.lessons[j], 'COMPLETED');
          
          newUnits[i] = UnitModel(
            id: unit.id,
            unitId: unit.unitId,
            sectionId: unit.sectionId,
            title: unit.title,
            description: unit.description,
            colorHex: unit.colorHex,
            orderIndex: unit.orderIndex,
            lessons: newLessons,
          );
          
          completedUnitIndex = i;
          completedLessonIndex = j;
          found = true;
          break;
        }
      }
      if (found) break;
    }
    
    if (!found) {
      debugPrint('⚠️ [OPTIMISTIC] Could not find level $completedLevelId to unlock next');
      return;
    }

    // 2. Find and unlock NEXT level
    // Logic: Same unit -> Next unit same section -> First unit next section
    
    // Try next lesson in same unit
    if (completedLessonIndex + 1 < newUnits[completedUnitIndex].lessons.length) {
      // Next level in same unit
      List<LessonNode> newLessons = List.from(newUnits[completedUnitIndex].lessons);
      newLessons[completedLessonIndex + 1] = _copyLessonWithStatus(newLessons[completedLessonIndex + 1], 'UNLOCKED');
      
      newUnits[completedUnitIndex] = _copyUnitWithLessons(newUnits[completedUnitIndex], newLessons);
      
      debugPrint('🔓 [OPTIMISTIC] Unlocked next level in SAME unit');
    } else {
      // Unit completed! Try next unit
      if (completedUnitIndex + 1 < newUnits.length) {
        // Next unit exists
        List<LessonNode> newLessons = List.from(newUnits[completedUnitIndex + 1].lessons);
        
        if (newLessons.isNotEmpty) {
           // Unlock first level of next unit
           newLessons[0] = _copyLessonWithStatus(newLessons[0], 'UNLOCKED');
           
           newUnits[completedUnitIndex + 1] = _copyUnitWithLessons(newUnits[completedUnitIndex + 1], newLessons);
           
           debugPrint('🔓 [OPTIMISTIC] Unlocked first level of NEXT unit');
        }
      } else {
        debugPrint('🏆 [OPTIMISTIC] All content completed!');
      }
    }
    
    // 3. Update state immediately
    units = newUnits;
    _sortUnitsAndLessons();
    notifyListeners();
  }

  LessonNode _copyLessonWithStatus(LessonNode lesson, String status) {
    return LessonNode(
      id: lesson.id,
      pathId: lesson.pathId,
      title: lesson.title,
      description: lesson.description,
      iconName: lesson.iconName,
      status: status,
      stars: lesson.stars,
      orderIndex: lesson.orderIndex,
      levelId: lesson.levelId,
    );
  }
  
  UnitModel _copyUnitWithLessons(UnitModel unit, List<LessonNode> lessons) {
    return UnitModel(
        id: unit.id,
        unitId: unit.unitId,
        sectionId: unit.sectionId,
        title: unit.title,
        description: unit.description,
        colorHex: unit.colorHex,
        orderIndex: unit.orderIndex,
        lessons: lessons,
    );
  }

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
      debugPrint('⚠️ Failed to get userId from JWT: $e');
      // Google login only - no local fallback
    }
    
    if (userId == null) return;
    
    // ✅ Server-side handling: Progress is submitted by LessonController
    // Here we just refresh the data to reflect changes
    await loadProgress();
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
    
    // ✅ STRICT LINEAR: ALL levels locked by default
    // Backend will determine which level to unlock
    final updatedLessons = unit.lessons
        .map((lesson) {
          return LessonNode(
            id: lesson.id,
            pathId: lesson.pathId,
            title: lesson.title,
            description: lesson.description,
            iconName: lesson.iconName,
            status: 'LOCKED', // All locked - backend controls unlock
            stars: lesson.stars,
            orderIndex: lesson.orderIndex,
            levelId: lesson.levelId,
          );
        })
        .toList();
    return UnitModel(
      id: unit.id,
      unitId: unit.unitId,
      sectionId: unit.sectionId,
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