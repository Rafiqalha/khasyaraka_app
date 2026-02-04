import 'package:dio/dio.dart';
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/core/auth/local_auth_service.dart';
import 'package:scout_os_app/features/mission/subfeatures/sku/models/sku_model.dart';

class SkuRepository {
  SkuRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Environment.apiBaseUrl,
                connectTimeout: Duration(milliseconds: Environment.connectTimeout),
                receiveTimeout: Duration(milliseconds: Environment.receiveTimeout),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final userId = await _authService.getCurrentUserId();
          if (userId != null && userId.isNotEmpty) {
            options.headers['X-User-Id'] = userId;
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final LocalAuthService _authService = LocalAuthService();

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
    final userId = await _authService.getCurrentUserId();
    final response = await _dio.post('/sku/submit', data: {
      'user_id': userId,
      'sku_point_id': pointId,
      'answers': answers,
    });
    return SkuSubmitResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
