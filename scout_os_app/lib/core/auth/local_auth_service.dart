import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUser {
  LocalUser({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    this.isPro = false,
    this.gugusDepan,
  });

  final String id;
  final String name;
  final String username;
  final String password;
  final bool isPro;
  final String? gugusDepan;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'password': password,
        'is_pro': isPro,
        'gugus_depan': gugusDepan,
      };

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
        // Defensive type casting: handle both int and String for id
        id: json['id'] is int 
            ? json['id'].toString() 
            : (json['id'] as String? ?? ''),
        name: json['name']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        isPro: json['is_pro'] == true || json['isPro'] == true,
        gugusDepan: json['gugus_depan']?.toString(),
      );
}

class LocalUserStats {
  LocalUserStats({
    required this.streak, 
    required this.totalXp,
    this.lastActiveDate,
  });

  final int streak;
  final int totalXp;
  final DateTime? lastActiveDate;

  Map<String, dynamic> toJson() => {
        'streak': streak,
        'total_xp': totalXp,
        'last_active_date': lastActiveDate?.toIso8601String(),
      };

  factory LocalUserStats.fromJson(Map<String, dynamic> json) => LocalUserStats(
        // Defensive type casting: handle both String and int for numeric fields
        streak: json['streak'] is int 
            ? json['streak'] as int
            : (json['streak'] is String 
                ? int.tryParse(json['streak'] as String) ?? 0
                : (json['streak'] as num?)?.toInt() ?? 0),
        totalXp: json['total_xp'] is int
            ? json['total_xp'] as int
            : (json['total_xp'] is String
                ? int.tryParse(json['total_xp'] as String) ?? 0
                : (json['total_xp'] as num?)?.toInt() ?? 0),
        lastActiveDate: json['last_active_date'] != null
            ? DateTime.tryParse(json['last_active_date'] as String)
            : null,
      );
}

class LocalAuthService {
  static const _usersKey = 'local_users';
  static const _currentUserKey = 'local_current_user_id';
  static const _statsPrefix = 'local_user_stats_';
  static const _userDataPrefix = 'user_data_';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<LocalUser>> getUsers() async {
    await init();
    final raw = _prefs?.getString(_usersKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((item) => LocalUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<LocalUser?> getCurrentUser() async {
    await init();
    final userId = _prefs?.getString(_currentUserKey);
    if (userId == null) return null;
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getCurrentUserId() async {
    await init();
    return _prefs?.getString(_currentUserKey);
  }

  Future<LocalUser> register({
    required String name,
    required String username,
    required String password,
    String? gugusDepan,
  }) async {
    await init();
    final users = await getUsers();
    final normalized = username.trim().toLowerCase();
    final exists = users.any((user) => user.username.toLowerCase() == normalized);
    if (exists) {
      throw Exception('Username sudah digunakan.');
    }

    final userId = _generateId();
    final user = LocalUser(
      id: userId,
      name: name.trim(),
      username: normalized,
      password: password,
      isPro: false,
      gugusDepan: gugusDepan?.trim().isEmpty ?? true ? null : gugusDepan?.trim(),
    );

    users.add(user);
    await _prefs?.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
    await _prefs?.setString(_currentUserKey, userId);
    return user;
  }

  Future<LocalUser> login({
    required String username,
    required String password,
  }) async {
    await init();
    final users = await getUsers();
    final normalized = username.trim().toLowerCase();
    final user = users.firstWhere(
      (u) => u.username.toLowerCase() == normalized,
      orElse: () => LocalUser(id: '', name: '', username: '', password: ''),
    );
    if (user.id.isEmpty || user.password != password) {
      throw Exception('Username atau password salah.');
    }
    await _prefs?.setString(_currentUserKey, user.id);
    return user;
  }

  Future<void> logout() async {
    await init();
    await _prefs?.remove(_currentUserKey);
  }

  Future<LocalUserStats> getUserStats(String userId) async {
    await init();
    final raw = _prefs?.getString('$_statsPrefix$userId');
    if (raw == null || raw.isEmpty) {
      return LocalUserStats(streak: 0, totalXp: 0);
    }
    return LocalUserStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUserStats(String userId, LocalUserStats stats) async {
    await init();
    await _prefs?.setString(
      '$_statsPrefix$userId',
      jsonEncode(stats.toJson()),
    );
  }

  /// Update user stats with XP earned and calculate daily streak
  /// 
  /// **XP Logic:** Adds xpEarned to current totalXp
  /// **Streak Logic:**
  /// - Same Day: If lastActiveDate == today, streak remains unchanged
  /// - Consecutive Day: If lastActiveDate was yesterday, streak++
  /// - Gap: If lastActiveDate was before yesterday, streak = 1 (Reset)
  /// 
  /// **Anti-Farming:** XP is only awarded if xpEarned > 0 (caller should check if level was previously completed)
  Future<void> updateUserStats({
    required String userId,
    required int xpEarned,
  }) async {
    await init();
    
    // Load current stats
    final currentStats = await getUserStats(userId);
    
    // ✅ CRITICAL: XP must ONLY come from backend response, NOT calculated here
    // This function should ONLY update streak and last_active_date
    // XP should be fetched from API response, not calculated
    // Keep current XP (from API) - don't add xpEarned
    final newTotalXp = currentStats.totalXp; // ✅ Keep current XP (from API)
    
    // Calculate streak based on lastActiveDate
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Normalize to midnight
    final lastActiveDate = currentStats.lastActiveDate;
    
    int newStreak;
    if (lastActiveDate == null) {
      // First time playing - start streak at 1
      newStreak = 1;
    } else {
      final lastActive = DateTime(
        lastActiveDate.year,
        lastActiveDate.month,
        lastActiveDate.day,
      );
      
      // Compare dates (year, month, day only)
      if (lastActive.year == today.year && 
          lastActive.month == today.month && 
          lastActive.day == today.day) {
        // Same day - streak remains unchanged
        newStreak = currentStats.streak;
      } else {
        final yesterday = today.subtract(const Duration(days: 1));
        if (lastActive.year == yesterday.year && 
            lastActive.month == yesterday.month && 
            lastActive.day == yesterday.day) {
          // Consecutive day - increment streak
          newStreak = currentStats.streak + 1;
        } else {
          // Gap detected - reset streak to 1
          newStreak = 1;
        }
      }
    }
    
    // Save updated stats
    final updatedStats = LocalUserStats(
      streak: newStreak,
      totalXp: newTotalXp,
      lastActiveDate: today, // Update last active date to today
    );
    
    debugPrint('💾 [UPDATE_STATS] Saving updated stats: XP=$newTotalXp (was ${currentStats.totalXp}, +$xpEarned), Streak=$newStreak (was ${currentStats.streak})');
    
    await saveUserStats(userId, updatedStats);
    
    // CRITICAL: Verify save by reading back
    final verifyStats = await getUserStats(userId);
    if (verifyStats.totalXp == newTotalXp && verifyStats.streak == newStreak) {
      debugPrint('✅ [UPDATE_STATS] Stats saved successfully and verified');
    } else {
      debugPrint('⚠️ [UPDATE_STATS] Stats verification failed: Expected XP=$newTotalXp Streak=$newStreak, Got XP=${verifyStats.totalXp} Streak=${verifyStats.streak}');
    }
  }

  /// Profile image path (local file path). Key: user_data_$userId.
  Future<String?> getProfileImagePath(String userId) async {
    await init();
    final raw = _prefs?.getString('$_userDataPrefix$userId');
    if (raw == null || raw.isEmpty) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data['profile_image_path'] as String?;
  }

  Future<void> saveProfileImagePath(String userId, String? path) async {
    await init();
    final key = '$_userDataPrefix$userId';
    final raw = _prefs?.getString(key);
    final data = raw != null && raw.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>)
        : <String, dynamic>{};
    if (path == null || path.isEmpty) {
      data.remove('profile_image_path');
    } else {
      data['profile_image_path'] = path;
    }
    await _prefs?.setString(key, jsonEncode(data));
  }

  String _generateId() {
    final rand = Random();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'user_${ts}_${rand.nextInt(9999)}';
  }
}
