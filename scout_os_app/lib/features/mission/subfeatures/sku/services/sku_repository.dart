import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';
import 'package:scout_os_app/features/auth/data/auth_repository.dart';

/// SKU Repository - Handles all SKU-related API calls
/// 
/// ✅ Uses ApiDioProvider which automatically handles JWT token
/// ✅ Google login only - no LocalAuthService needed
class SkuRepository {
  SkuRepository({Dio? dio})
      : _dio = dio ?? ApiDioProvider.getDio();

  final Dio _dio;
  final AuthRepository _authRepo = AuthRepository();

  Future<SkuOverviewModel> fetchOverview() async {
    final response = await _dio.get('/sku/overview');
    return SkuOverviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SkuPointStatusModel>> fetchPoints(String level) async {
    final response = await _dio.get('/sku/$level/points');
    final data = response.data as Map<String, dynamic>;
    final points = data['points'] as List<dynamic>;
    return points.map((item) => SkuPointStatusModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<SkuPointDetailModel> fetchPointDetail(String pointId) async {
    final response = await _dio.get('/sku/points/$pointId');
    return SkuPointDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SkuSubmitResultModel> submitAnswers({
    required String pointId,
    required List<int> answers,
  }) async {
    // Get userId from JWT token (Google login)
    String? userId;
    try {
      final currentUser = await _authRepo.getCurrentUser();
      userId = currentUser.id;
    } catch (e) {
      throw Exception('User not authenticated. Please login again.');
    }
    
    final response = await _dio.post('/sku/submit', data: {
      'user_id': userId,
      'sku_point_id': pointId,
      'answers': answers,
    });
    return SkuSubmitResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
