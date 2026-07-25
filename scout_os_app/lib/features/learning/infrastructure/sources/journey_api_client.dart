import 'package:dio/dio.dart';
import '../dtos/learning_request_dtos.dart';

/// Journey API client for fetching curriculum journeys from backend.
abstract class JourneyApiClient {
  Future<Map<String, dynamic>> fetchJourneyJson(JourneyRequest request);
}

class DioJourneyApiClient implements JourneyApiClient {
  final Dio dio;

  DioJourneyApiClient(this.dio);

  @override
  Future<Map<String, dynamic>> fetchJourneyJson(JourneyRequest request) async {
    final response = await dio.get('/academies/${request.academyId}/journeys/${request.curriculumId}');
    final data = response.data as Map<String, dynamic>;
    
    final curriculum = data['curriculum'] as Map<String, dynamic>? ?? {};
    final journey = data['journey'] as Map<String, dynamic>? ?? {};
    
    final units = curriculum['units'] as List<dynamic>? ?? [];
    List<dynamic> allNodes = [];
    
    for (var unit in units) {
      final lessons = unit['lessons'] as List<dynamic>? ?? [];
      for (var lesson in lessons) {
         final nodes = lesson['nodes'] as List<dynamic>? ?? [];
         allNodes.addAll(nodes);
      }
    }
    
    return {
      'id': journey['id']?.toString() ?? curriculum['id']?.toString() ?? request.curriculumId,
      'title': curriculum['title']?.toString() ?? 'Learning Journey',
      'nodes': allNodes.map((n) => {
        'id': n['id']?.toString() ?? '',
        'type': n['type']?.toString() ?? 'NOTEBOOK',
        'title': n['title']?.toString() ?? 'Untitled',
        'estimatedSeconds': n['estimatedSeconds'] ?? 300,
        'isRequired': n['isRequired'] ?? true,
        'telemetryKey': n['telemetryKey']?.toString() ?? n['id']?.toString() ?? '',
      }).toList(),
    };
  }
}
