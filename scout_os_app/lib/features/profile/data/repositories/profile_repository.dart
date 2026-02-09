/// Profile Repository
/// 
/// Handles API calls for user profile and stats operations.
/// Uses Dio with JWT authentication.
/// Implements SWR caching for performance.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';

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

  // ✅ Memory Cache (Singleton Pattern)
  static UserStatsModel? _cachedStats;
  static DateTime? _lastStatsFetch;
  static const Duration _statsCacheTtl = Duration(minutes: 5); // 5 minutes cache

  /// Clear memory cache (maintain static state)
  static void clearMemoryCache() {
    _cachedStats = null;
    _lastStatsFetch = null;
    debugPrint('🧹 [PROFILE] Memory cache cleared');
  }

  /// Get current user stats from API with SWR caching + Memory Cache
  /// 
  /// Endpoint: GET /api/v1/users/me
  /// Returns: UserStatsModel with totalXp and streak
  /// 
  /// Throws:
  ///   Exception if API call fails
  Future<UserStatsModel> getUserStats({bool forceRefresh = false}) async {
    const cacheKey = LocalCacheService.keyUserProfile;
    
    // ✅ 1. MEMORY CACHE (Level 1 - Instant)
    if (!forceRefresh && _cachedStats != null) {
      final isExpired = _lastStatsFetch != null && 
          DateTime.now().difference(_lastStatsFetch!) > _statsCacheTtl;
      
      if (!isExpired) {
        debugPrint('🧠 [PROFILE] Returning MEMORY cached stats (Instant)');
        return _cachedStats!;
      }
    }
    
    try {
      // ✅ 2. DISK CACHE (Level 2 - SWR)
      if (!forceRefresh) {
        final cachedData = await LocalCacheService.get<dynamic>(cacheKey);
        if (cachedData != null) {
          debugPrint('📦 [SWR] Returning DISK cached user stats');
          
          final Map<String, dynamic> data = cachedData is String 
              ? jsonDecode(cachedData) as Map<String, dynamic>
              : cachedData as Map<String, dynamic>;
          
          final stats = UserStatsModel.fromJson(data);
          
          // Update memory cache
          _cachedStats = stats;
          _lastStatsFetch = DateTime.now(); // Optimistic update
          
          // Background revalidation
          _runBackgroundRevalidation();
          
          return stats;
        }
      }
      
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
        
        debugPrint('✅ [PROFILE] Fetched user stats: XP=${stats.totalXp}, Streak=${stats.streak}');
        
        // Update both caches
        _cachedStats = stats;
        _lastStatsFetch = DateTime.now();
        await LocalCacheService.put(cacheKey, jsonEncode(data), ttl: LocalCacheService.shortTtl);
        
        return stats;
      } else {
        throw Exception('Invalid response format from users/me API');
      }
    } on DioException catch (e) {
      debugPrint('❌ [PROFILE] Dio error: ${e.message}');
      
      // ✅ Offline Resilience: Try everything to return something
      if (_cachedStats != null) return _cachedStats!;
      
      final staleCache = await LocalCacheService.get<dynamic>(cacheKey);
      if (staleCache != null) {
        debugPrint('📦 [SWR] Returning stale stats (offline mode)');
        final Map<String, dynamic> data = staleCache is String 
            ? jsonDecode(staleCache) as Map<String, dynamic>
            : staleCache as Map<String, dynamic>;
        return UserStatsModel.fromJson(data);
      }
      
      if (e.response != null) {
        // Handle 401 Unauthorized
        if (e.response!.statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        }
      }
      throw Exception('Failed to fetch user stats: ${e.message}');
    } catch (e) {
      debugPrint('❌ [PROFILE] Unexpected error: $e');
      if (_cachedStats != null) return _cachedStats!;
      throw Exception('Failed to fetch user stats: $e');
    }
  }
  
  // Detached background fetch
  void _runBackgroundRevalidation() {
    Future(() async {
      try {
        debugPrint('🔄 [SWR] Background revalidating user stats...');
        final response = await _dio.get('/users/me');
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          
          await LocalCacheService.put(
            LocalCacheService.keyUserProfile, 
            jsonEncode(data), 
            ttl: LocalCacheService.shortTtl,
          );
          
          // Update memory cache silently
           _cachedStats = UserStatsModel.fromJson(data);
          _lastStatsFetch = DateTime.now();
          
          debugPrint('✅ [SWR] User stats revalidation complete');
        }
      } catch (e) {
        debugPrint('⚠️ [SWR] User stats revalidation failed: $e');
      }
    });
  }

  /// Get current user profile from API
  /// 
  /// Endpoint: GET /api/v1/users/me
  /// Returns: ApiUser with full profile data
  Future<ApiUser> getCurrentUser() async {
    return await _authRepo.getCurrentUser();
    // Note: AuthRepository should also implement caching if needed, 
    // but usually stats are fetched more often than full profile.
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
