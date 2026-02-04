import 'environment.dart';

class ApiConfig {
  static const String baseUrl = Environment.apiBaseUrl;

  // Header standar untuk setiap request JSON
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Header dengan Token Auth (Dipanggil saat user sudah login)
  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static const Duration connectionTimeout = Duration(milliseconds: Environment.connectTimeout);
  static const Duration receiveTimeout = Duration(milliseconds: Environment.receiveTimeout);
}