import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/core/config/environment.dart';

final catalogProvider = FutureProvider.family<List<dynamic>, String>((ref, resource) async {
  final dio = ApiDioProvider.getDio();
  final host = Environment.apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
  final response = await dio.get('$host/api/v2/catalog/$resource');
  
  if (response.statusCode == 200) {
    return response.data['items'] as List<dynamic>;
  } else {
    throw Exception('Failed to load catalog $resource');
  }
});
