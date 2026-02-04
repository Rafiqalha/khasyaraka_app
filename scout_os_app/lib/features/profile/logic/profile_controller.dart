import 'package:flutter/material.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/data/repositories/activity_repository.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    ProfileRepository? profileRepo,
    AuthRepository? authRepo,
    TrainingController? trainingController,
  })  : _profileRepo = profileRepo ?? ProfileRepository(),
        _authRepo = authRepo ?? AuthRepository() {
    _trainingController = trainingController;
    if (_trainingController != null) {
      _trainingController!.addListener(_onTrainingUpdate);
    }
    loadProfile();
  }

  final ProfileRepository _profileRepo;
  final AuthRepository _authRepo;
  final ActivityRepository _activityRepo = ActivityRepository();
  TrainingController? _trainingController;

  bool isLoading = false;
  String? errorMessage;

  ApiUser? currentUser;
  int _totalXp = 0;
  int _streak = 0;

  /// Active dates (YYYY-MM-DD) from activity log. Real data, no mock.
  List<String> activityLog = [];

  String get displayName => currentUser?.name ?? 'Pengguna';
  bool get isPro => currentUser?.isPro ?? false;
  int get totalXp => _totalXp;
  int get streak => _streak;

  /// Rank title from XP tiers. Real data, no mock.
  String get rankTitle => _rankFromXp(totalXp).title;

  /// Rank badge / level label from XP. Real data, no mock.
  String get rankBadge => _rankFromXp(totalXp).badge;

  static ({String title, String badge}) _rankFromXp(int xp) {
    if (xp >= 2000) return (title: 'Penegak Garuda', badge: 'Level 6');
    if (xp >= 1000) return (title: 'Penegak Laksana', badge: 'Level 5');
    if (xp >= 600) return (title: 'Penegak Bantara', badge: 'Level 4');
    if (xp >= 300) return (title: 'Siaga Tata', badge: 'Level 3');
    if (xp >= 100) return (title: 'Siaga Bantu', badge: 'Level 2');
    return (title: 'Siaga Mula', badge: 'Level 1');
  }

  void _onTrainingUpdate() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔄 [PROFILE] Loading profile from API...');

      // Fetch current user from API
      currentUser = await _authRepo.getCurrentUser();
      
      // Fetch stats from API
      final stats = await _profileRepo.getUserStats();
      _totalXp = stats.totalXp;
      _streak = stats.streak;

      // Fetch activity log (still from local for now, can be moved to API later)
      if (currentUser != null) {
        activityLog = await _activityRepo.getActivityLog(currentUser!.id);
      } else {
        activityLog = [];
      }

      debugPrint('✅ [PROFILE] Loaded profile: XP=$_totalXp, Streak=$_streak');
    } catch (e) {
      debugPrint('❌ [PROFILE] Error loading profile: $e');
      errorMessage = e.toString();
      _totalXp = 0;
      _streak = 0;
      activityLog = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all state for logout - CRITICAL for preventing data leak between users
  /// This ensures User B doesn't see User A's profile data
  void clearState() {
    debugPrint('🧹 ProfileController.clearState() - Clearing all user data');
    
    // Reset all state to default values
    currentUser = null;
    _totalXp = 0;
    _streak = 0;
    activityLog = [];
    errorMessage = null;
    isLoading = false;
    
    // Force notify listeners to update UI
    notifyListeners();
    
    debugPrint('✅ ProfileController state cleared');
  }

  Future<void> logout() async {
    // Clear state first
    clearState();
    
    // Then call auth repository logout
    await _authRepo.logout();
  }

  @override
  void dispose() {
    _trainingController?.removeListener(_onTrainingUpdate);
    super.dispose();
  }
}
