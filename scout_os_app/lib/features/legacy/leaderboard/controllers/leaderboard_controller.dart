/// Leaderboard Controller
///
/// Manages leaderboard state and fetches data from remote API only.
/// Uses LeaderboardRepository for API calls.
/// NO local storage fallback - purely API-driven.

import 'package:flutter/foundation.dart';
import 'package:scout_os_app/features/leaderboard/services/leaderboard_repository.dart';
import 'package:scout_os_app/features/leaderboard/models/leaderboard_model.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';

class LeaderboardController extends ChangeNotifier {
  final LeaderboardRepository _repository;
  final AuthRepository _authRepo;

  bool _isLoading = false;
  String? _errorMessage;
  LeaderboardData? _leaderboardData;
  String? _currentUserId;
  
  String _activeCategory = 'quiz'; // 'quiz' is Normal Mode (XP)
  String _activeScope = 'global';

  LeaderboardController({
    LeaderboardRepository? repository,
    AuthRepository? authRepo,
  }) : _repository = repository ?? LeaderboardRepository(),
       _authRepo = authRepo ?? AuthRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LeaderboardData? get leaderboardData => _leaderboardData;
  List<LeaderboardUser> get topUsers => _leaderboardData?.topUsers ?? [];
  MyRank? get myRank => _leaderboardData?.myRank;
  String get activeCategory => _activeCategory;
  String get activeScope => _activeScope;

  /// Load leaderboard from remote API
  ///
  /// Fetches top users and current user's rank from backend.
  /// Purely API-driven - no local storage fallback.
  Future<void> loadLeaderboard({
    int limit = 50, 
    String? category, 
    String? scope,
  }) async {
    if (category != null) _activeCategory = category;
    if (scope != null) _activeScope = scope;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔄 [LEADERBOARD] Loading leaderboard from API (category: $_activeCategory, scope: $_activeScope)...');

      // Get current user ID and Location ID for rank calculation
      String userLocationId = '';
      try {
        final currentUser = await _authRepo.getCurrentUser();
        _currentUserId = currentUser.id;
        if (_activeScope == 'kecamatan') {
          userLocationId = currentUser.kecamatanId ?? '';
        } else if (_activeScope == 'kota') {
          userLocationId = currentUser.kabupatenId ?? '';
        } else if (_activeScope == 'provinsi') {
          userLocationId = currentUser.provinsiId ?? '';
        }
        debugPrint('✅ [LEADERBOARD] Current user ID: $_currentUserId, LocationID: $userLocationId');
      } catch (e) {
        debugPrint('⚠️ [LEADERBOARD] Could not get current user: $e');
        _currentUserId = null;
      }

      // Fetch leaderboard from API
      _leaderboardData = await _repository.fetchLeaderboard(
        limit: limit,
        category: _activeCategory,
        scope: _activeScope,
        locationId: userLocationId,
      );

      debugPrint(
        '✅ [LEADERBOARD] Loaded ${_leaderboardData!.topUsers.length} users from API',
      );
      
      // ✅ CRITICAL FALLBACK: Override 0 XP with real XP from user profile
      if (_leaderboardData != null && _leaderboardData!.myRank != null && _leaderboardData!.myRank!.xp == 0) {
        try {
          final profileRepo = ProfileRepository();
          final userStats = await profileRepo.getUserStats(forceRefresh: false); // Use cached first
          if (userStats.totalXp > 0) {
            final oldRank = _leaderboardData!.myRank!;
            var topUsersList = List<LeaderboardUser>.from(_leaderboardData!.topUsers);
            final currentUser = await _authRepo.getCurrentUser();
            
            final isUserInTopList = topUsersList.any((u) => u.id == currentUser.id.toString());
            
            if (!isUserInTopList) {
               topUsersList.add(
                 LeaderboardUser(
                   id: currentUser.id.toString(),
                   name: currentUser.name,
                   xp: userStats.totalXp,
                   rank: oldRank.rank > 0 ? oldRank.rank : 1, 
                   avatar: currentUser.pictureUrl,
                   level: 'Siaga', 
                   rankInfo: oldRank.rankInfo,
                 )
               );
               topUsersList.sort((a, b) => b.xp.compareTo(a.xp));
               
               for (int i = 0; i < topUsersList.length; i++) {
                 final u = topUsersList[i];
                 topUsersList[i] = LeaderboardUser(
                   id: u.id, name: u.name, xp: u.xp, rank: i + 1, avatar: u.avatar, level: u.level, rankInfo: u.rankInfo
                 );
               }
            }

            _leaderboardData = LeaderboardData(
              topUsers: topUsersList,
              myRank: MyRank(
                rank: oldRank.rank > 0 ? oldRank.rank : (topUsersList.indexWhere((u) => u.id == currentUser.id.toString()) + 1),
                xp: userStats.totalXp, // Inject real XP
                avatar: currentUser.pictureUrl, // Inject avatar
                rankInfo: oldRank.rankInfo,
              ),
            );
            debugPrint('🔄 [LEADERBOARD] Fallback XP injected: ${userStats.totalXp}');
          }
        } catch (e) {
          debugPrint('⚠️ [LEADERBOARD] Failed to fallback XP: $e');
        }
      }

      debugPrint('✅ [LEADERBOARD] Controller hashCode: ${hashCode}');

      if (_leaderboardData!.myRank != null) {
        debugPrint(
          '   My rank: #${_leaderboardData!.myRank!.rank} (${_leaderboardData!.myRank!.xp} XP)',
        );
      } else {
        debugPrint(
          '   My rank: Not available (user might not be in leaderboard)',
        );
      }

      // ✅ CRITICAL DEBUG: Verify data assignment
      debugPrint(
        '📊 [LEADERBOARD] After assignment: topUsers.length=${topUsers.length}, myRank=${myRank != null ? 'present' : 'null'}',
      );

      _isLoading = false;
      notifyListeners(); // ✅ CRITICAL: Notify listeners AFTER data assignment

      // ✅ CRITICAL DEBUG: Verify after notifyListeners
      debugPrint(
        '📊 [LEADERBOARD] After notifyListeners: topUsers.length=${topUsers.length}, myRank=${myRank != null ? 'present' : 'null'}',
      );
    } catch (e) {
      debugPrint('❌ [LEADERBOARD] Error loading leaderboard: $e');
      _errorMessage = 'Gagal memuat leaderboard: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh leaderboard data
  Future<void> refresh({int limit = 50}) async {
    await loadLeaderboard(
      limit: limit, 
      category: _activeCategory, 
      scope: _activeScope,
    );
  }

  /// Clear state (useful for logout)
  void clearState() {
    _leaderboardData = null;
    _currentUserId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
