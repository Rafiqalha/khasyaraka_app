/// Leaderboard Repository
///
/// Handles API calls for leaderboard operations.
/// Uses Dio with JWT authentication.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/leaderboard/models/leaderboard_model.dart';

class LeaderboardRepository {
  final Dio _dio;

  LeaderboardRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  /// Fetch leaderboard from API
  ///
  /// Args:
  ///   limit: Number of top users to return (default 50, max 100)
  ///
  /// Returns:
  ///   LeaderboardData with topUsers and myRank
  ///
  /// Throws:
  ///   Exception if API call fails
  Future<LeaderboardData> fetchLeaderboard({
    int limit = 50,
    String category = 'rank',
    String scope = 'global',
    String locationId = '',
  }) async {
    try {
      // ✅ CRITICAL DEBUG: Log endpoint and base URL
      final baseUrl = _dio.options.baseUrl;
      final endpoint = '/leaderboard';
      final fullUrl = '$baseUrl$endpoint';
      debugPrint('🔍 [LEADERBOARD_REPO] Base URL: $baseUrl');
      debugPrint('🔍 [LEADERBOARD_REPO] Endpoint: $endpoint');
      debugPrint('🔍 [LEADERBOARD_REPO] Full URL: $fullUrl');

      // ✅ CRITICAL DEBUG: Check token before request
      try {
        final token = await ApiDioProvider.getToken();
        if (token != null && token.isNotEmpty) {
          debugPrint(
            '✅ [LEADERBOARD_REPO] Token found: length=${token.length}, prefix=${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          );
        } else {
          debugPrint(
            '⚠️ [LEADERBOARD_REPO] No token found in SharedPreferences',
          );
        }
      } catch (e) {
        debugPrint('⚠️ [LEADERBOARD_REPO] Error checking token: $e');
      }

      debugPrint(
        '📊 [LEADERBOARD_REPO] Fetching leaderboard (limit: $limit)...',
      );

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'limit': limit,
          'category': category,
          'scope': scope,
          if (locationId.isNotEmpty) 'location_id': locationId,
        },
      );

      // ✅ CRITICAL DEBUG: Log response status and headers
      debugPrint(
        '✅ [LEADERBOARD_REPO] Response status: ${response.statusCode}',
      );
      debugPrint(
        '🔍 [LEADERBOARD_REPO] Response headers: ${response.headers.map}',
      );

      // Backend returns: { "success": true, "data": {...}, "message": "..." }
      final responseData = response.data as Map<String, dynamic>;

      debugPrint(
        '📊 [LEADERBOARD_REPO] Raw response type: ${responseData.runtimeType}',
      );
      debugPrint(
        '📊 [LEADERBOARD_REPO] Raw response keys: ${responseData.keys.toList()}',
      );
      debugPrint('📊 [LEADERBOARD_REPO] Raw response: $responseData');

      // ✅ CRITICAL DEBUG: Check response structure
      if (!responseData.containsKey('success')) {
        debugPrint(
          '❌ [LEADERBOARD_REPO] ERROR: Response does not have "success" key!',
        );
        debugPrint('   Available keys: ${responseData.keys.toList()}');
      }

      if (!responseData.containsKey('data')) {
        debugPrint(
          '❌ [LEADERBOARD_REPO] ERROR: Response does not have "data" key!',
        );
        debugPrint('   Available keys: ${responseData.keys.toList()}');
      }

      if (responseData['success'] == true && responseData['data'] != null) {
        final rawData = responseData['data'];
        Map<String, dynamic> data;

        if (rawData is List) {
          data = {
            'top_users': rawData,
            'my_rank': null,
          };

          // Fetch my_rank separately since backend separates them
          try {
            final token = await ApiDioProvider.getToken();
            if (token != null && token.isNotEmpty) {
              final rankResponse = await _dio.get(
                '/leaderboard/me',
                queryParameters: {
                  'category': category,
                  'scope': scope,
                  if (locationId.isNotEmpty) 'location_id': locationId,
                },
              );
              if (rankResponse.data['success'] == true && rankResponse.data['data'] != null) {
                data['my_rank'] = rankResponse.data['data'];
              }
            }
          } catch (e) {
            debugPrint('⚠️ [LEADERBOARD_REPO] Failed to fetch my_rank: $e');
          }
        } else {
          data = rawData as Map<String, dynamic>;
        }

        debugPrint(
          '✅ [LEADERBOARD_REPO] Response structure OK: success=true, data is Map',
        );
        debugPrint('🔍 [LEADERBOARD_REPO] Data keys: ${data.keys.toList()}');
        debugPrint(
          '📊 [LEADERBOARD_REPO] Parsing data: top_users=${data['top_users']?.length ?? 0}, my_rank=${data['my_rank'] != null ? 'present' : 'null'}',
        );

        // ✅ CRITICAL DEBUG: Check top_users structure
        if (data['top_users'] != null) {
          if (data['top_users'] is List) {
            debugPrint(
              '✅ [LEADERBOARD_REPO] top_users is List with ${(data['top_users'] as List).length} items',
            );
            if ((data['top_users'] as List).isNotEmpty) {
              final firstUser = (data['top_users'] as List)[0];
              debugPrint(
                '📊 [LEADERBOARD_REPO] First user raw data: $firstUser',
              );
              debugPrint(
                '📊 [LEADERBOARD_REPO] First user type: ${firstUser.runtimeType}',
              );
              if (firstUser is Map) {
                debugPrint(
                  '📊 [LEADERBOARD_REPO] First user keys: ${firstUser.keys.toList()}',
                );
              }
            } else {
              debugPrint('⚠️ [LEADERBOARD_REPO] top_users is empty list');
            }
          } else {
            debugPrint(
              '❌ [LEADERBOARD_REPO] ERROR: top_users is not a List! Type: ${data['top_users'].runtimeType}',
            );
          }
        } else {
          debugPrint('⚠️ [LEADERBOARD_REPO] top_users is null');
        }

        // ✅ CRITICAL DEBUG: Check my_rank structure
        if (data['my_rank'] != null) {
          debugPrint(
            '✅ [LEADERBOARD_REPO] my_rank is present, type: ${data['my_rank'].runtimeType}',
          );
          if (data['my_rank'] is Map) {
            debugPrint(
              '📊 [LEADERBOARD_REPO] my_rank keys: ${(data['my_rank'] as Map).keys.toList()}',
            );
            debugPrint('📊 [LEADERBOARD_REPO] my_rank raw: ${data['my_rank']}');
          }
        } else {
          debugPrint('⚠️ [LEADERBOARD_REPO] my_rank is null');
        }

        final leaderboardData = LeaderboardData.fromJson(data);

        debugPrint(
          '✅ [LEADERBOARD_REPO] Parsed successfully: topUsers=${leaderboardData.topUsers.length}, myRank=${leaderboardData.myRank != null ? 'present' : 'null'}',
        );

        if (leaderboardData.topUsers.isNotEmpty) {
          debugPrint(
            '   Top user: ${leaderboardData.topUsers[0].name} - ${leaderboardData.topUsers[0].xp} XP (rank #${leaderboardData.topUsers[0].rank})',
          );
        } else {
          debugPrint(
            '⚠️ [LEADERBOARD_REPO] WARNING: Parsed topUsers is empty!',
          );
        }

        // ✅ CRITICAL: Debug myRank parsing
        if (leaderboardData.myRank != null) {
          debugPrint(
            '✅ [LEADERBOARD_REPO] My rank parsed successfully: rank=${leaderboardData.myRank!.rank}, xp=${leaderboardData.myRank!.xp}',
          );

          // ✅ Validate: rank should be >= 1 if xp > 0
          if (leaderboardData.myRank!.xp > 0 &&
              leaderboardData.myRank!.rank == 0) {
            debugPrint(
              '❌ [LEADERBOARD_REPO] ERROR: myRank has XP=${leaderboardData.myRank!.xp} but rank=0! Backend should return rank >= 1.',
            );
          }

          // ✅ Validate: rank should be >= 1
          if (leaderboardData.myRank!.rank < 1) {
            debugPrint(
              '❌ [LEADERBOARD_REPO] ERROR: myRank.rank=${leaderboardData.myRank!.rank} is < 1! This should not happen.',
            );
          }
        } else {
          debugPrint(
            '⚠️ [LEADERBOARD_REPO] My rank is NULL - user might not be in leaderboard or not authenticated',
          );

          // ✅ Debug: Check raw data
          if (data['my_rank'] != null) {
            debugPrint(
              '⚠️ [LEADERBOARD_REPO] WARNING: Raw data has my_rank but parsing failed! Raw: ${data['my_rank']}',
            );
          } else {
            debugPrint(
              '⚠️ [LEADERBOARD_REPO] Raw data does not have my_rank field',
            );
          }
        }

        return leaderboardData;
      } else {
        debugPrint('❌ [LEADERBOARD_REPO] ERROR: Invalid response format!');
        debugPrint('   success: ${responseData['success']}');
        debugPrint('   data: ${responseData['data']}');
        throw Exception(
          'Invalid response format from leaderboard API: success=${responseData['success']}, data=${responseData['data']}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [LEADERBOARD_REPO] Dio error: ${e.message}');
      if (e.response != null) {
        debugPrint('   Status: ${e.response!.statusCode}');
        debugPrint('   Headers: ${e.response!.headers.map}');
        debugPrint('   Body: ${e.response!.data}');
      } else {
        debugPrint('   No response object (network error?)');
      }
      throw Exception('Failed to fetch leaderboard: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('❌ [LEADERBOARD_REPO] Unexpected error: $e');
      debugPrint('   Stack trace: $stackTrace');
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  /// Fetch compact live leaderboard optimized for real-time polling.
  ///
  /// Backend Big O: O(log N + M + K) — sublinear via Redis ZREVRANGE.
  /// N = total users, M = limit, K = profile cache keys.
  Future<Map<String, dynamic>> fetchLeaderboardLive({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/leaderboard/live',
        queryParameters: {'limit': limit},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return {'top': [], 'me': null, 'total': 0};
    } catch (e) {
      debugPrint('⚠️ [LEADERBOARD_LIVE] Error: $e');
      return {'top': [], 'me': null, 'total': 0};
    }
  }
}
