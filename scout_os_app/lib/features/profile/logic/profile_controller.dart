import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scout_os_app/features/home/logic/training_controller.dart';
import 'package:scout_os_app/features/profile/data/repositories/activity_repository.dart';
import 'package:scout_os_app/features/profile/data/repositories/profile_repository.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    ProfileRepository? profileRepo,
    AuthRepository? authRepo,
    TrainingController? trainingController, // Keep param for API compatibility but don't use
  })  : _profileRepo = profileRepo ?? ProfileRepository(),
        _authRepo = authRepo ?? AuthRepository() {
    loadProfile();
  }

  final ProfileRepository _profileRepo;
  final AuthRepository _authRepo;
  final ActivityRepository _activityRepo = ActivityRepository();

  bool isLoading = false;
  bool _isLoadingProfile = false;
  String? errorMessage;

  ApiUser? currentUser;
  int _totalXp = 0;
  int _streak = 0;

  /// Active dates (YYYY-MM-DD) from activity log. Real data, no mock.
  List<String> activityLog = [];

  // Local overrides for profile customization
  String? _localPhotoPath;
  String? _localName;

  String get displayName => _localName ?? currentUser?.name ?? 'Pengguna';
  String? get photoUrl => _localPhotoPath ?? currentUser?.username; // Fallback to username if no photo (UI handles this)
  
  // Expose local path specifically for FileImage widget
  String? get localPhotoPath => _localPhotoPath;

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

      // Fetch activity log (still from local for now, can be moved to API later)
      if (currentUser != null) {
        activityLog = await _activityRepo.getActivityLog(currentUser!.id);
        
        // Load local overrides
        await _loadLocalProfileData();
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

  Future<void> _loadLocalProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = currentUser?.id ?? '';
      if (userId.isEmpty) return;

      _localName = prefs.getString('local_name_$userId');
      
      final savedPath = prefs.getString('local_photo_$userId');
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) {
          _localPhotoPath = savedPath;
        } else {
          // Clean up invalid path
          await prefs.remove('local_photo_$userId');
          _localPhotoPath = null;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading local profile data: $e');
    }
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    
    try {
      _localName = newName.trim();
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      final userId = currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        await prefs.setString('local_name_$userId', _localName!);
      }
    } catch (e) {
      debugPrint('❌ Error updating name: $e');
    }
  }

  Future<void> updatePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimize size
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        // Copy to permanent storage
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${currentUser?.id ?? "guest"}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

        _localPhotoPath = savedImage.path;
        notifyListeners();
        
        final prefs = await SharedPreferences.getInstance();
        final userId = currentUser?.id ?? '';
        if (userId.isNotEmpty) {
          await prefs.setString('local_photo_$userId', _localPhotoPath!);
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating photo: $e');
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
    _localPhotoPath = null;
    _localName = null;
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
    super.dispose();
  }
}
