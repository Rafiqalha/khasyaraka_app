import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/data/repositories/activity_repository.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    ProfileRepository? profileRepo,
    AuthRepository? authRepo,
    TrainingController? trainingController,
    AuthController? authController,
  }) : _profileRepo = profileRepo ?? ProfileRepository(),
       _authRepo = authRepo ?? AuthRepository(),
       _authController = authController {
    loadProfile();

    // Listen to AuthController changes for auto-refresh
    if (_authController != null) {
      _authController.addListener(_onAuthStateChanged);
    }
  }

  final ProfileRepository _profileRepo;
  final AuthRepository _authRepo;
  final ActivityRepository _activityRepo = ActivityRepository();
  final AuthController? _authController;

  bool isLoading = false;
  bool _isLoadingProfile = false;
  String? errorMessage;

  ApiUser? currentUser;
  int _totalXp = 0;
  int _streak = 0;

  /// Active dates (YYYY-MM-DD) from activity log. Real data, no mock.
  List<String> activityLog = [];

  String get displayName => currentUser?.name ?? 'Pengguna';
  String? get photoUrl => currentUser?.pictureUrl;

  // Local photo path (only used as temp preview while uploading)
  String? _localPhotoPath;
  String? get localPhotoPath => _localPhotoPath;

  bool get isPro => currentUser?.isPro ?? false;
  int get totalXp => _totalXp;
  int get streak => _streak;

  /// Rank title from highest achieved rank or XP tiers.
  String _highestRankTitle = '';
  String get rankTitle {
    if (_highestRankTitle.isNotEmpty) return _highestRankTitle;
    return _rankFromXp(totalXp).title;
  }

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

  Future<void> loadProfile() async {
    // ✅ Deduplication guard - prevent concurrent loads
    if (_isLoadingProfile) {
      debugPrint('⏭️ [PROFILE] Skipping duplicate loadProfile call');
      return;
    }
    _isLoadingProfile = true;

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

      // Fetch activity log
      if (currentUser != null) {
        activityLog = await _activityRepo.getActivityLog(currentUser!.id);
        
        // Fallback: If local log is empty but backend says we have a streak, generate it!
        if (activityLog.isEmpty && _streak > 0) {
          final now = DateTime.now();
          for (int i = 0; i < _streak; i++) {
            final d = now.subtract(Duration(days: i));
            activityLog.add("${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}");
          }
        }
        
        _fetchHighestRankAsync();
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
      _isLoadingProfile = false; // ✅ Reset lock
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;

    final oldName = currentUser?.name;
    try {
      // Optimistic update
      if (currentUser != null) {
        currentUser = ApiUser(
          id: currentUser!.id,
          name: newName.trim(),
          username: currentUser!.username,
          pictureUrl: currentUser!.pictureUrl,
          isPro: currentUser!.isPro,
          gugusDepan: currentUser!.gugusDepan,
        );
        notifyListeners();
      }

      // Sync to backend (updates DB + invalidates Redis profile cache)
      await _profileRepo.updateProfileName(newName.trim());
      // Invalidate AuthRepository cache so next getCurrentUser() returns fresh data
      _authRepo.invalidateCache();

      // Refresh leaderboard so rank_page shows the new name
      _refreshLeaderboard();

      debugPrint('✅ [PROFILE] Name synced to backend: $newName');
    } catch (e) {
      debugPrint('❌ [PROFILE] Error syncing name to backend: $e');
      // Revert optimistic update on failure
      if (currentUser != null && oldName != null) {
        currentUser = ApiUser(
          id: currentUser!.id,
          name: oldName,
          username: currentUser!.username,
          pictureUrl: currentUser!.pictureUrl,
          isPro: currentUser!.isPro,
          gugusDepan: currentUser!.gugusDepan,
        );
        notifyListeners();
      }
    }
  }

  Future<void> updatePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return;

      // Show local preview immediately
      _localPhotoPath = image.path;
      notifyListeners();

      // Upload to backend (saves file + updates DB picture_url + invalidates Redis cache)
      final newPictureUrl = await _profileRepo.uploadAvatar(File(image.path));

      // Update currentUser with new picture_url from backend
      if (currentUser != null) {
        currentUser = ApiUser(
          id: currentUser!.id,
          name: currentUser!.name,
          username: currentUser!.username,
          pictureUrl: newPictureUrl,
          isPro: currentUser!.isPro,
          gugusDepan: currentUser!.gugusDepan,
        );
      }
      _localPhotoPath = null; // Clear local preview, use backend URL now
      notifyListeners();

      // Invalidate AuthRepository cache
      _authRepo.invalidateCache();

      // Refresh leaderboard so rank_page shows the new photo
      _refreshLeaderboard();

      debugPrint('✅ [PROFILE] Avatar synced to backend: $newPictureUrl');
    } catch (e) {
      debugPrint('❌ [PROFILE] Error uploading avatar: $e');
      _localPhotoPath = null;
      notifyListeners();
    }
  }

  void _refreshLeaderboard() {
    // Leaderboard handles its own refresh
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
    _localPhotoPath = null;
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

  Future<void> _onAuthStateChanged() async {
    if (_authController?.currentUser != null && !isLoading) {
      debugPrint('🔄 [PROFILE] Auto-refreshing due to auth change');
      await loadProfile();
    }
  }

  Future<void> _fetchHighestRankAsync() async {
    // Legacy rank calculation disabled
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    if (_authController != null) {
      _authController!.removeListener(_onAuthStateChanged);
    }
    super.dispose();
  }
}
