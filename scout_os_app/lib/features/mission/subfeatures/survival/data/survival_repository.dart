import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/survival/data/survival_mastery_model.dart';

class SurvivalRepository {
  SurvivalRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  final Dio _dio;

  /// Get all mastery stats for the current user
  Future<AllMasteryResponse> fetchMastery() async {
    try {
      final response = await _dio.get('/survival/mastery');
      return AllMasteryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch mastery: ${e.message}');
    }
  }

  /// Record a tool action and gain XP
  Future<RecordActionResponse> recordAction({
    required String toolType,
    int xpGained = 10,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/survival/action',
        data: {
          'tool_type': toolType,
          'xp_gained': xpGained,
          'action_metadata': metadata ?? {},
        },
      );
      return RecordActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to record action: ${e.message}');
    }
  }
}
