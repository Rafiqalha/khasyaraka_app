import 'package:flutter/foundation.dart';

// Import local repositories (Assuming these exist or will be created)
import 'package:scout_os_app/features/dashboard/data/repositories/user_repository.dart';
// Note: You might need to create these or stub them
// import 'package:scout_os_app/features/leaderboard/data/leaderboard_repository.dart'; 
// import 'package:scout_os_app/features/mission/data/mission_repository.dart';

/// Dashboard State Management (Provider)
/// 
/// Orchestrates parallel data fetching from multiple domains.
/// Implements "Offline-First" with "Silent Background Update".
class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  
  // TODO: Inject other repositories here
  // final LeaderboardRepository _leaderboardRepo;
  // final MissionRepository _missionRepo;

  DashboardViewModel({
    UserRepository? userRepo,
  }) : _userRepo = userRepo ?? UserRepository();

  // --- STATE ---
  
  bool _isLoading = true; // Initial full-screen/shimmer loading
  bool _isBackgroundUpdating = false; // Silent update indicator
  String? _errorMessage;
  
  UserStats? _userData;
  // List<LeaderboardEntry>? _leaderboardData;
  // List<Mission>? _missionData;

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  bool get isBackgroundUpdating => _isBackgroundUpdating;
  String? get errorMessage => _errorMessage;
  UserStats? get userData => _userData;

  bool get hasData => _userData != null;

  // --- LOGIC ---

  /// Initialize Dashboard Data
  /// Called from UI via WidgetsBinding.instance.addPostFrameCallback
  Future<void> initDashboard() async {
    // Only show full loading if we have NO data (Cold Start / First Install)
    if (!hasData) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isBackgroundUpdating = true;
      notifyListeners();
    }

    try {
      debugPrint('🚀 [DASHBOARD] Starting parallel fetch...');
      
      // ✅ PARALLEL EXECUTION with Independent Error Handling
      // We use Future.wait but wrap each call to prevent one failure from crashing all
      await Future.wait([
        _fetchUserStats(),
        // _fetchLeaderboard(),
        // _fetchMissions(),
      ]);

      _errorMessage = null;

    } catch (e) {
      debugPrint('❌ [DASHBOARD] Critical error: $e');
      _errorMessage = "Failed to load dashboard. Please pull to refresh.";
    } finally {
      _isLoading = false;
      _isBackgroundUpdating = false;
      notifyListeners();
      debugPrint('🏁 [DASHBOARD] Fetch complete. Has Data: $hasData');
    }
  }

  /// Fetch User Stats with Stream (yields Cache -> Network)
  Future<void> _fetchUserStats() async {
    try {
      // Listen to the stream. 
      // First event: Cache (if exists). 
      // Second event: Network (fresh).
      await for (final stats in _userRepo.getUserStatsStream()) {
        _userData = stats;
        // If we got cached data, stop the "Full Loading" immediately
        if (_isLoading) {
          _isLoading = false; 
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ [DASHBOARD] User Stats Error: $e');
      // Non-fatal: Don't set global error if other parts might succeed
      // rely on cache if available.
    }
  }

  // Example for other data
  /*
  Future<void> _fetchLeaderboard() async {
    try {
      // await for (final data in _leaderboardRepo.getLeaderboardStream()) { ... }
    } catch (e) {
      debugPrint('⚠️ [DASHBOARD] Leaderboard Error: $e');
    }
  }
  */

  /// Pull-to-refresh action
  Future<void> refresh() async {
    _isBackgroundUpdating = true;
    notifyListeners();
    await initDashboard();
  }
}
