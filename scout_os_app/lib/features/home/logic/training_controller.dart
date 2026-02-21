import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:scout_os_app/core/services/admob_service.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import '../data/repositories/training_repository.dart';
import '../data/models/training_path.dart';
import '../data/models/training_section.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';
import '../data/datasources/training_service.dart';

class TrainingController extends ChangeNotifier {
  // ✅ Fixed duplicate method definition
  final TrainingRepository _repository = TrainingRepository();
  final AuthRepository _authRepo = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  final TrainingService _service = TrainingService();
  final AuthController? _authController;

  bool isLoading = false;
  bool _isPathLoading = false; // ✅ Deduplication lock
  bool _isProgressLoading = false; // ✅ Deduplication lock
  bool _isStatsLoading = false; // ✅ Deduplication lock
  String? errorMessage;
  List<UnitModel> units = [];
  List<SectionWithUnits> sectionsWithUnits = []; // Backend-driven sections

  // Duolingo-style progress tracking
  int userXp = 0;
  int userStreak = 0;
  int userLongestStreak = 0;
  int userHearts = 5; // Lives (Source of Truth)
  int maxHearts = 5;
  // REMOVED: bonusHearts - User requested strict 5 max sync

  // Service
  final AdMobService _adMobService = AdMobService();

  // REMOVED: Real-time hearts regeneration system (User request: AdMob only)
  // Timer? _heartsTimer;
  // DateTime? _lastHeartRegeneration;
  // static const Duration _heartRegenerationInterval = Duration(minutes: 1); // 1 minute

  bool disposed = false;

  TrainingController({AuthController? authController})
    : _authController = authController {
    // Listen to AuthController changes for auto-refresh
    if (_authController != null) {
      _authController.addListener(_onAuthStateChanged);
    }
    _adMobService.initialize(); // Initialize AdMob
    _loadHeartsFromCache(); // ✅ Load hearts immediately on startup
  }

  /// Load hearts from local cache (Source of Truth for Lives)
  Future<void> _loadHeartsFromCache() async {
    try {
      final cachedHearts = await LocalCacheService.get<int>('user_hearts');
      // Default to 5 if null (First install)
      userHearts = cachedHearts ?? 5;

      // REMOVED: bonusHearts loading

      debugPrint(
        '💚 [INIT] Loaded userHearts from cache: $cachedHearts (Using: $userHearts)',
      );
      notifyListeners();

      // No more regeneration timer
    } catch (e) {
      debugPrint('⚠️ [INIT] Failed to load hearts cache: $e');
      userHearts = 5;
    }
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
      sectionsWithUnits = sections
          .map((s) => SectionWithUnits(section: s, units: []))
          .toList();

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
            final sectionUnits = cachedUnits
                .where((u) => u.sectionId == sectionId)
                .toList();

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
        } catch (e) {
          debugPrint('⚠️ [LOAD_UNITS] Cache parse failed: $e');
          units = [];
        }
      } else {
        units = [];
      }

      // ✅ FALLBACK: If cache is empty/failed/missing, fetch from API immediately
      if (units.isEmpty) {
        debugPrint(
          '🌐 [LOAD_UNITS] Cache miss. Fetching units for all ${sectionsWithUnits.length} sections...',
        );

        // Fetch all sections in parallel
        await Future.wait(
          sectionsWithUnits.map((s) async {
            try {
              final fetchedUnits = await _repository.getLearningPathBySection(
                s.section.id,
              );

              // Find and update the section in our list
              final index = sectionsWithUnits.indexWhere(
                (item) => item.section.id == s.section.id,
              );
              if (index != -1) {
                sectionsWithUnits[index] = SectionWithUnits(
                  section: s.section,
                  units: fetchedUnits,
                );
              }
            } catch (e) {
              debugPrint(
                '⚠️ [LOAD_UNITS] Failed to fetch units for ${s.section.id}: $e',
              );
            }
          }),
        );

        // Rebuild flattened list from the updated sections
        _rebuildFlattenedUnits();

        // Cache the fresh result
        if (units.isNotEmpty) {
          await LocalCacheService.put(
            'units_cache',
            units.map((e) => e.toJson()).toList(),
          );
          debugPrint(
            '✅ [LOAD_UNITS] Fetched and cached ${units.length} total units',
          );
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
      final sectionIndex = sectionsWithUnits.indexWhere(
        (s) => s.section.id == sectionId,
      );
      if (sectionIndex == -1) return;

      // Ensure we don't overwrite if already loaded?
      // User might want to refresh. So we fetch simple.

      final sectionUnits = await _repository.getLearningPathBySection(
        sectionId,
      );

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
      await LocalCacheService.put(
        'units_cache',
        units.map((e) => e.toJson()).toList(),
      );

      notifyListeners();
      debugPrint(
        '✅ [LAZY_LOAD] Loaded ${sectionUnits.length} units for section $sectionId',
      );

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
    await Future.wait([loadProgress(), loadUserStats()]);
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

  /// CRITICAL: Sync updated `units` back into `sectionsWithUnits`.
  /// TrainingMapPage reads sectionsWithUnits, so both must stay in sync.
  void _syncUnitsToSections() {
    // Build a lookup from unitId → updated UnitModel
    final unitMap = <String, UnitModel>{};
    for (final unit in units) {
      unitMap[unit.unitId] = unit;
    }

    sectionsWithUnits = sectionsWithUnits.map((sw) {
      final updatedUnits = sw.units.map((oldUnit) {
        return unitMap[oldUnit.unitId] ?? oldUnit;
      }).toList();
      return SectionWithUnits(section: sw.section, units: updatedUnits);
    }).toList();
  }

  Future<void> loadProgress() async {
    if (_isProgressLoading) {
      debugPrint('⏭️ [LOAD_PROGRESS] Skipping duplicate call');
      return;
    }
    _isProgressLoading = true;
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
        debugPrint(
          '⚠️ [LOAD_PROGRESS] No userId found, but Level 1 will still be unlocked',
        );
        // CRITICAL: Even without userId, Level 1 should be unlocked
        // Use _lockAllLessons which already unlocks Level 1
        units = units.map(_lockAllLessons).toList();
        notifyListeners();
        return;
      }

      // userId is guaranteed non-null here (checked above)
      final nonNullUserId = userId;

      debugPrint(
        '🔄 [LOAD_PROGRESS] Loading progress for userId: $nonNullUserId',
      );

      // ✅ 1. SERVER-SIDE SOURCE OF TRUTH (No Local Cache)
      // We skip local storage entirely to ensure fresh data.
      // Loading state is handled by the UI.

      // ✅ 2. NETWORK FETCH (Primary Source)
      // Fetch progress from backend (Redis-backed <50ms response)
      Map<String, String> progressMap = {};

      try {
        debugPrint(
          '📡 [LOAD_PROGRESS] Fetching GLOBAL progress from backend...',
        );

        // Single Batch Request (Global)
        progressMap = await _repository.fetchUserProgress(
          nonNullUserId,
          sectionId: null,
        );

        debugPrint(
          '✅ [LOAD_PROGRESS] Backend returned ${progressMap.length} progress entries total',
        );
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
    } catch (e, stackTrace) {
      debugPrint('❌ [LOAD_PROGRESS] ERROR: $e');
      debugPrint('   Stack trace: $stackTrace');
      rethrow; // Re-throw to let caller handle
    } finally {
      _isProgressLoading = false;
    }
  }

  // ✅ HELPER: Update units with progress map
  void _updateUnitsWithProgress(
    Map<String, dynamic> progressMap,
    String userId,
  ) {
    debugPrint('🔄 [LOAD_PROGRESS] Updating units with progress data...');

    // CRITICAL: Create new list instances to ensure widget rebuild
    final updatedUnits = units.map((unit) {
      final updatedLessons = unit.lessons.map((lesson) {
        final levelId = lesson.levelId ?? lesson.id.toString();
        // Get status from backend (UPPERCASE) and normalize legacy values
        String? rawStatus = progressMap[levelId]?.toString().toUpperCase();
        // Normalize: AVAILABLE/IN_PROGRESS → UNLOCKED (legacy backend statuses)
        String? status = rawStatus;
        if (status == 'AVAILABLE' || status == 'IN_PROGRESS') {
          status = 'UNLOCKED';
        }

        // ✅ PARALLEL UNITS: Level 1 of each unit is always UNLOCKED
        final isLevel1 = levelId.endsWith('_l1');
        final finalStatus = status ?? (isLevel1 ? 'UNLOCKED' : 'LOCKED');

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
    _sortUnitsAndLessons();
    _syncUnitsToSections(); // ✅ CRITICAL: Sync to sectionsWithUnits (read by TrainingMapPage)
    notifyListeners();
  }

  /// Optimistically unlock next level locally without waiting for backend
  /// This ensures UI updates INSTANTLY when returning from lesson
  void unlockNextLevelLocally(String completedLevelId) {
    debugPrint(
      '🚀 [OPTIMISTIC] Unlocking next level locally for $completedLevelId',
    );

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
          debugPrint(
            '✅ [OPTIMISTIC] Found level $completedLevelId at unit[$i].lesson[$j], marking as COMPLETED',
          );
          debugPrint('   Previous status: ${unit.lessons[j].status}');

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

          debugPrint('   New status: ${newLessons[j].status}');

          completedUnitIndex = i;
          completedLessonIndex = j;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (!found) {
      debugPrint(
        '⚠️ [OPTIMISTIC] Could not find level $completedLevelId to unlock next',
      );
      return;
    }

    // 2. Find and unlock NEXT level
    // Logic: Same unit -> Next unit same section -> First unit next section

    // Try next lesson in same unit
    if (completedLessonIndex + 1 <
        newUnits[completedUnitIndex].lessons.length) {
      // Next level in same unit
      List<LessonNode> newLessons = List.from(
        newUnits[completedUnitIndex].lessons,
      );
      newLessons[completedLessonIndex + 1] = _copyLessonWithStatus(
        newLessons[completedLessonIndex + 1],
        'UNLOCKED',
      );

      newUnits[completedUnitIndex] = _copyUnitWithLessons(
        newUnits[completedUnitIndex],
        newLessons,
      );

      debugPrint('🔓 [OPTIMISTIC] Unlocked next level in SAME unit');
    } else {
      // Unit completed! Try next unit
      if (completedUnitIndex + 1 < newUnits.length) {
        // Next unit exists
        List<LessonNode> newLessons = List.from(
          newUnits[completedUnitIndex + 1].lessons,
        );

        if (newLessons.isNotEmpty) {
          // Unlock first level of next unit
          newLessons[0] = _copyLessonWithStatus(newLessons[0], 'UNLOCKED');

          newUnits[completedUnitIndex + 1] = _copyUnitWithLessons(
            newUnits[completedUnitIndex + 1],
            newLessons,
          );

          debugPrint('🔓 [OPTIMISTIC] Unlocked first level of NEXT unit');
        }
      } else {
        debugPrint('🏆 [OPTIMISTIC] All content completed!');
      }
    }

    // 3. Update state immediately
    units = newUnits;
    _sortUnitsAndLessons();
    _syncUnitsToSections(); // ✅ CRITICAL: Sync to sectionsWithUnits
    notifyListeners();
  }

  /// Apply backend-confirmed result for precise optimistic UI updates.
  /// Uses the actual status and next_level_id from the submit_progress response.
  void applyBackendResult({
    required String completedLevelId,
    required String completedStatus,
    String? nextLevelId,
  }) {
    debugPrint(
      '🎯 [BACKEND_RESULT] Applying: level=$completedLevelId, status=$completedStatus, next=$nextLevelId',
    );

    List<UnitModel> newUnits = List.from(units);

    // 1. Set completed level to backend-confirmed status (COMPLETED or UNLOCKED)
    for (int i = 0; i < newUnits.length; i++) {
      final unit = newUnits[i];
      for (int j = 0; j < unit.lessons.length; j++) {
        if (unit.lessons[j].levelId == completedLevelId) {
          List<LessonNode> newLessons = List.from(unit.lessons);
          newLessons[j] = _copyLessonWithStatus(
            unit.lessons[j],
            completedStatus,
          );
          newUnits[i] = _copyUnitWithLessons(unit, newLessons);
          debugPrint(
            '✅ [BACKEND_RESULT] Set $completedLevelId → $completedStatus',
          );
          break;
        }
      }
    }

    // 2. If backend unlocked a next level, set it to UNLOCKED
    if (nextLevelId != null) {
      for (int i = 0; i < newUnits.length; i++) {
        final unit = newUnits[i];
        for (int j = 0; j < unit.lessons.length; j++) {
          if (unit.lessons[j].levelId == nextLevelId) {
            List<LessonNode> newLessons = List.from(unit.lessons);
            newLessons[j] = _copyLessonWithStatus(unit.lessons[j], 'UNLOCKED');
            newUnits[i] = _copyUnitWithLessons(unit, newLessons);
            debugPrint('🔓 [BACKEND_RESULT] Set $nextLevelId → UNLOCKED');
            break;
          }
        }
      }
    }

    // 3. Update state immediately
    units = newUnits;
    _sortUnitsAndLessons();
    _syncUnitsToSections(); // ✅ CRITICAL: Sync to sectionsWithUnits
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

  Future<void> loadUserStats({bool forceRefresh = false}) async {
    if (_isStatsLoading) {
      debugPrint('⏭️ [LOAD_STATS] Skipping duplicate call');
      return;
    }
    _isStatsLoading = true;
    debugPrint(
      '🔄 [LOAD_STATS] Starting loadUserStats from API... (forceRefresh=$forceRefresh)',
    );

    try {
      // CRITICAL: Fetch stats from remote API
      final remoteStats = await _profileRepo.getUserStats(
        forceRefresh: forceRefresh,
      );

      userXp = remoteStats.totalXp;
      userStreak = remoteStats.streak;
      userLongestStreak = remoteStats.longestStreak;
      maxHearts = remoteStats.maxHearts; // Update max hearts from backend

      userHearts = remoteStats.hearts;

      // Update cache with fresh data
      await LocalCacheService.put('user_hearts', userHearts);
      debugPrint(
        '💚 [LOAD_STATS] Updated hearts from API: $userHearts (Cache updated)',
      );

      debugPrint(
        '📊 [LOAD_STATS] Stats updated: XP=$userXp, Streak=$userStreak, Hearts=$userHearts',
      );

      // Check if hearts reached 0
      if (userHearts <= 0) {
        debugPrint('💚 [LOAD_STATS] Hearts reached 0. Suggest watching ad.');
        // No regeneration timer
      } else {
        debugPrint('💚 [LOAD_STATS] Hearts > 0');
      }

      notifyListeners();

      debugPrint('✅ [LOAD_STATS] Stats loaded successfully');
    } catch (e) {
      debugPrint('❌ [LOAD_STATS] Error loading stats from API: $e');
      // Don't throw - set to 0 as fallback
      userXp = 0;
      userStreak = 0;
      notifyListeners();
    } finally {
      _isStatsLoading = false;
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

  /// Decrement hearts (for wrong answers, failed lessons, etc.)
  Future<void> decrementHearts({int amount = 1}) async {
    try {
      debugPrint('💚 [DECREMENT_HEARTS] Decreasing hearts by $amount...');

      final oldHearts = userHearts;
      userHearts = (userHearts - amount).clamp(0, maxHearts);

      debugPrint(
        '💚 [DECREMENT_HEARTS] Hearts changed: $oldHearts → $userHearts',
      );

      // Update UI immediately (Optimistic)
      notifyListeners();

      // ✅ SAVE TO CACHE (Critical)
      await LocalCacheService.put('user_hearts', userHearts);

      // ✅ SYNC TO BACKEND
      try {
        final currentUser = await _authRepo.getCurrentUser();
        if (currentUser.id.isNotEmpty) {
          await _service.decrementHearts(
            userId: currentUser.id,
            amount: amount,
          );
          debugPrint('✅ [DECREMENT_HEARTS] Synced to backend');
        }
      } catch (e) {
        debugPrint('⚠️ [DECREMENT_HEARTS] Failed to sync to backend: $e');
      }
    } catch (e) {
      debugPrint('❌ [DECREMENT_HEARTS] Error decrementing hearts: $e');
    }
  }

  /// Watch Ad to get hearts
  /// Users can watch ads freely as long as hearts < maxHearts (5)
  /// Once hearts == 5, ads are blocked until hearts decrease
  void watchAdForHearts() {
    if (userHearts >= maxHearts) {
      debugPrint(
        '💚 [AdMob] Hearts already full ($userHearts/$maxHearts), cannot watch ad',
      );
      return;
    }

    _adMobService.showRewardedAd(
      onUserEarnedReward: (reward) {
        debugPrint(
          '🎁 [AdMob] Reward granted for type: ${reward.type} amount: ${reward.amount}',
        );

        // STRICT: Only accept "hearts" reward type in RELEASE mode
        // Google test ad units always return "coins" — cannot be changed
        // Real ad unit must have Reward Item Name = "hearts" in AdMob console
        if (!kDebugMode && reward.type != "hearts") {
          debugPrint(
            '🚫 [AdMob] Unexpected reward type: ${reward.type}. Expected: hearts. Ignoring.',
          );
          return;
        }
        if (kDebugMode && reward.type != "hearts") {
          debugPrint(
            '⚠️ [AdMob] DEBUG MODE: Accepting test reward type "${reward.type}" (prod requires "hearts")',
          );
        }

        // In DEBUG mode: Google test ads do NOT trigger SSV callbacks
        // So we call the debug-increment endpoint directly to simulate SSV
        // In RELEASE mode: Wait for real SSV to process, then refresh from Redis
        if (kDebugMode) {
          debugPrint(
            '🧪 [AdMob] DEBUG: Calling debug-increment endpoint (test ads skip SSV)',
          );
          _simulateDebugHeartIncrement();
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            debugPrint('🔄 [AdMob] Refreshing hearts from Redis...');
            refreshHearts();
          });
        }
      },
      onAdFailed: () {
        debugPrint('❌ [AdMob] Failed to show ad');
      },
      onAdDismissed: () {
        debugPrint('🎬 [AdMob] Ad dismissed by user');
      },
    );
  }

  /// [DEBUG ONLY] Simulates SSV heart increment for test ads
  /// Google test ad units do NOT trigger SSV callbacks,
  /// so we call the debug-increment endpoint directly
  Future<void> _simulateDebugHeartIncrement() async {
    try {
      final currentUser = await _authRepo.getCurrentUser();
      if (currentUser.id.isEmpty) return;

      await _service.debugIncrementHearts(userId: currentUser.id);
      debugPrint('🧪 [DEBUG] Heart increment simulated, refreshing...');

      // Now refresh to see the updated value
      await refreshHearts();
    } catch (e) {
      debugPrint('❌ [DEBUG] Failed to simulate heart increment: $e');
    }
  }

  /// Manual hearts regeneration trigger (for testing and manual refresh)
  Future<void> manualHeartsRegeneration() async {
    try {
      debugPrint('💚 [MANUAL_REGEN] Manual hearts regeneration triggered...');
      // Sync from backend to see if anything changed
      await loadUserStats(forceRefresh: true);
      debugPrint(
        '💚 [MANUAL_REGEN] Manual regeneration completed (Fetched from Backend)',
      );
    } catch (e) {
      debugPrint('❌ [MANUAL_REGEN] Error in manual regeneration: $e');
    }
  }

  // REMOVED: _stopHeartsTimer

  // REMOVED: _regenerateHearts

  // REMOVED: _startHeartsTimer, _stopHeartsTimer, _regenerateHearts

  // REMOVED: _startHeartsRegeneration

  /// Refresh hearts with regeneration check
  /// This method specifically checks if hearts should be regenerated based on time
  Future<void> refreshHearts() async {
    if (_isStatsLoading) return;

    _isStatsLoading = true;
    notifyListeners();

    try {
      debugPrint('💚 [REFRESH_HEARTS] Checking hearts regeneration...');

      final currentUser = await _authRepo.getCurrentUser();
      final userId = currentUser.id;

      if (userId.isEmpty) {
        debugPrint('⚠️ [REFRESH_HEARTS] No user ID found');
        return;
      }

      // Fetch hearts with regeneration check
      final heartsData = await _service.getHearts(userId: userId);

      final newHearts = heartsData['hearts'] ?? userHearts;
      final newMaxHearts = heartsData['max_hearts'] ?? maxHearts;

      // Check if hearts changed from 0 to >0
      final wasZero = userHearts == 0;
      userHearts = newHearts;
      maxHearts = newMaxHearts;

      if (wasZero && userHearts > 0) {
        debugPrint('💚 [REFRESH_HEARTS] Hearts restored from 0 to $userHearts');
      } else if (userHearts == 0 && wasZero == false) {
        debugPrint('💚 [REFRESH_HEARTS] Hearts reached 0');
      }

      final nextRegen = heartsData['next_regeneration_time'];
      debugPrint(
        '💚 [REFRESH_HEARTS] Updated: hearts=$userHearts/$maxHearts, next_regen=$nextRegen',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('❌ [REFRESH_HEARTS] Error refreshing hearts: $e');
    } finally {
      _isStatsLoading = false;
    }
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
    final updatedLessons = unit.lessons.map((lesson) {
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
  }

  /// Auto-refresh training data when AuthController state changes
  void _onAuthStateChanged() {
    // Check if controller is disposed before proceeding
    if (disposed) {
      debugPrint(
        '⚠️ [TRAINING] Controller disposed, skipping auth state change',
      );
      return;
    }

    if (_authController != null && _authController.currentUser != null) {
      debugPrint(
        '🔄 [TRAINING] AuthController state changed, refreshing training data...',
      );

      // Small delay to ensure AuthController state is fully updated
      Future.delayed(const Duration(milliseconds: 200), () async {
        // Check again if controller is disposed after delay
        if (disposed) {
          debugPrint(
            '⚠️ [TRAINING] Controller disposed during delay, skipping refresh',
          );
          return;
        }

        try {
          // Complete cache clearing for fresh start
          await _clearAllCache();

          // Reload all training data for new user
          await loadUnitsOnly();
          await loadProgress();
          await loadUserStats();
        } catch (e) {
          debugPrint('⚠️ [TRAINING] Error during auth state refresh: $e');
        }
      });
    }
  }

  /// Complete cache clearing for fresh start
  Future<void> _clearAllCache() async {
    try {
      debugPrint('🧹 [TRAINING] Clearing all cache for fresh start...');

      // Clear local cache
      await LocalCacheService.clear();

      // Clear any in-memory state
      units.clear();
      sectionsWithUnits.clear();

      // Reset stats to defaults
      userXp = 0;
      userStreak = 0;
      userHearts = 5;

      // Stop any running timers
      // _stopHeartsTimer();

      debugPrint('✅ [TRAINING] All cache cleared successfully');
    } catch (e) {
      debugPrint('⚠️ [TRAINING] Error clearing cache: $e');
    }
  }

  @override
  void dispose() {
    // Mark as disposed to prevent further operations
    disposed = true;

    // Remove listener to prevent memory leaks
    if (_authController != null) {
      _authController.removeListener(_onAuthStateChanged);
    }

    // Stop hearts timer to prevent memory leaks
    // _stopHeartsTimer();

    super.dispose();
  }

  // ✅ REMOVED: _persistUserStats() - Stats are managed by backend only
  // Use loadUserStats() to refresh stats from API
}
