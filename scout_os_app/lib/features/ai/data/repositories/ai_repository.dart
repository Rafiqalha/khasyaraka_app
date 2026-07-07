import 'package:scout_os_app/core/network/api_service.dart';
import 'package:scout_os_app/features/ai/data/models/chat_response.dart';

class AiRepository {
  final ApiService _apiService;

  AiRepository(this._apiService);

  Future<ChatResponse> sendMessage(String prompt) async {
    final response = await _apiService.post('/ai/chat', data: {
      'prompt': prompt,
    });
    
    // The ApiService handles errors and returns the Map directly if successful
    if (response is Map<String, dynamic>) {
      return ChatResponse.fromJson(response);
    }
    
    throw Exception('Invalid response format');
  }
}
