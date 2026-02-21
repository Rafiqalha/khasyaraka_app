import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:scout_os_app/core/data/base_repository.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';

/// User Stats Model (Simplified for Dashboard)
class UserStats {
  final int totalXp;
  final int streak;

  UserStats({required this.totalXp, required this.streak});

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXp: json['total_xp'] is int
          ? json['total_xp']
          : (int.tryParse(json['total_xp'].toString()) ?? 0),
      streak: json['streak'] is int
          ? json['streak']
          : (int.tryParse(json['streak'].toString()) ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {'total_xp': totalXp, 'streak': streak};
}

/// User Repository (Offline-First)
class UserRepository extends BaseRepository<UserStats> {
  final Dio _dio;

  UserRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  /// Get User Stats Stream (yielding Cache -> Network)
  Stream<UserStats> getUserStatsStream() {
    return fetchData(
      cacheKey: LocalCacheService.keyUserProfile,

      // ✅ API Call Logic
      apiCall: () async {
        final response = await _dio.get('/users/me');
        final data = response.data['data'];

        if (data == null) throw Exception('No data from API');

        return UserStats.fromJson(data);
      },

      // ✅ Serialization Logic
      fromJson: (json) {
        if (json is String) {
          return UserStats.fromJson(jsonDecode(json));
        }
        return UserStats.fromJson(json);
      },

      ttl: LocalCacheService.shortTtl, // 5 mins cache
    );
  }
}
