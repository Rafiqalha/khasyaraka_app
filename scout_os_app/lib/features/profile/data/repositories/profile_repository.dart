/// Profile Repository
/// 
/// Handles API calls for user profile and stats operations.
/// Uses Dio with JWT authentication.
/// NO local storage - purely API-driven.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';

/// User stats model from API
class UserStatsModel {
  final int totalXp;
  final int streak;
  final DateTime? lastActiveDate;

  UserStatsModel({
    required this.totalXp,
    this.streak = 0,
    this.lastActiveDate,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseLastActiveDate;
    if (json['last_active_date'] != null) {
      try {
        parseLastActiveDate = DateTime.parse(json['last_active_date'] as String);
      } catch (e) {
        parseLastActiveDate = null;
      }
    }

    return UserStatsModel(
      totalXp: json['total_xp'] is int
          ? json['total_xp'] as int
          : (json['total_xp'] is String
              ? int.tryParse(json['total_xp'] as String) ?? 0
              : (json['total_xp'] as num?)?.toInt() ?? 0),
      streak: json['streak'] is int
          ? json['streak'] as int
          : (json['streak'] is String
              ? int.tryParse(json['streak'] as String) ?? 0
              : (json['streak'] as num?)?.toInt() ?? 0),
      lastActiveDate: parseLastActiveDate,
    );
  }
}

class ProfileRepository {
  final Dio _dio;
  final AuthRepository _authRepo;

  ProfileRepository({
    Dio? dio,
    AuthRepository? authRepo,
  })  : _dio = dio ?? ApiDioProvider.getDio(),
        _authRepo = authRepo ?? AuthRepository();

  /// Get current user stats from API
  /// 
  /// Endpoint: GET /api/v1/users/me
  /// Returns: UserStatsModel with totalXp and streak
  /// 
  /// Throws:
  ///   Exception if API call fails
  Future<UserStatsModel> getUserStats() async {
    try {
      debugPrint('📊 [PROFILE] Fetching user stats from API...');
      
      final response = await _dio.get('/users/me');
      
      // Backend returns: { "success": true, "data": {...}, "message": "..." }
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        
        final stats = UserStatsModel(
          totalXp: data['total_xp'] is int
              ? data['total_xp'] as int
              : (data['total_xp'] is String
                  ? int.tryParse(data['total_xp'] as String) ?? 0
                  : (data['total_xp'] as num?)?.toInt() ?? 0),
          streak: data['streak'] is int
              ? data['streak'] as int
              : 0,
          lastActiveDate: data['last_active_date'] != null
              ? (() {
                  try {
                    return DateTime.parse(data['last_active_date'] as String);
                  } catch (e) {
                    return null;
                  }
                })()
              : null,
        );
        
        debugPrint('✅ [PROFILE] Fetched user stats: XP=${stats.totalXp}, Streak=${stats.streak}, LastActive=${stats.lastActiveDate?.toIso8601String().split('T')[0] ?? 'null'}');
        
        return stats;
      } else {
        throw Exception('Invalid response format from users/me API');
      }
    } on DioException catch (e) {
      debugPrint('❌ [PROFILE] Dio error: ${e.message}');
      if (e.response != null) {
        debugPrint('   Status: ${e.response!.statusCode}');
        debugPrint('   Body: ${e.response!.data}');
        
        // Handle 401 Unauthorized
        if (e.response!.statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        }
      }
      throw Exception('Failed to fetch user stats: ${e.message}');
    } catch (e) {
      debugPrint('❌ [PROFILE] Unexpected error: $e');
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  /// Get current user profile from API
  /// 
  /// Endpoint: GET /api/v1/users/me
  /// Returns: ApiUser with full profile data
  Future<ApiUser> getCurrentUser() async {
    return await _authRepo.getCurrentUser();
  }

  /// Update user stats (streak and last_active_date) on the server
  /// 
  /// ⚠️ CRITICAL: XP is NOT updated here - XP must ONLY come from POST /training/progress/submit
  /// 
  /// Endpoint: PUT /api/v1/users/me/stats
  /// 
  /// Args:
  ///   newXp: Ignored (kept for backward compatibility, but not sent to backend)
  ///   newStreak: New streak value (optional, defaults to 0)
  ///   lastActiveDate: Last active date (optional, defaults to today)
  /// 
  /// Throws:
  ///   Exception if API call fails
  Future<void> updateUserXp(
    int newXp, { // ✅ newXp is ignored - XP comes from submit_progress only
    int newStreak = 0,
    DateTime? lastActiveDate,
  }) async {
    try {
      final activeDate = lastActiveDate ?? DateTime.now();
      final dateString = '${activeDate.year}-${activeDate.month.toString().padLeft(2, '0')}-${activeDate.day.toString().padLeft(2, '0')}';
      
      debugPrint('📤 [PROFILE] Updating user stats on server: Streak=$newStreak, LastActive=$dateString (XP ignored - comes from submit_progress)');
      
      final response = await _dio.put(
        '/users/me/stats',
        data: {
          // ✅ CRITICAL: Do NOT send total_xp - XP is updated via POST /training/progress/submit only
          // 'total_xp': newXp, // ❌ REMOVED: XP must ONLY come from backend via submit_progress
          'streak': newStreak,
          'last_active_date': dateString,
        },
      );
      
      // Backend returns: { "success": true, "data": {...}, "message": "..." }
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['success'] == true) {
        debugPrint('✅ [PROFILE] User stats updated successfully on server');
      } else {
        throw Exception('Invalid response format from users/me/stats API');
      }
    } on DioException catch (e) {
      debugPrint('❌ [PROFILE] Dio error updating stats: ${e.message}');
      if (e.response != null) {
        debugPrint('   Status: ${e.response!.statusCode}');
        debugPrint('   Body: ${e.response!.data}');
        
        // Handle 401 Unauthorized
        if (e.response!.statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        }
      }
      throw Exception('Failed to update user stats: ${e.message}');
    } catch (e) {
      debugPrint('❌ [PROFILE] Unexpected error updating stats: $e');
      throw Exception('Failed to update user stats: $e');
    }
  }
}
