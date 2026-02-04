import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:scout_os_app/core/config/environment.dart';

class ApiClient {
  // Singleton Pattern (Agar instance-nya satu saja)
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Melakukan GET Request ke Backend
  Future<dynamic> get(String endpoint) async {
    // Gabungkan Base URL dengan Endpoint (misal: /training/path)
    final url = Uri.parse("${Environment.apiBaseUrl}$endpoint");
    
    try {
      if (kDebugMode) {
        debugPrint("📡 GET Request ke: $url");
      }
      
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (kDebugMode) {
        debugPrint("📥 Response Code: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        // Berhasil! Kembalikan data JSON
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Error Koneksi: $e");
      }
      throw Exception("Gagal terhubung ke server. Pastikan backend nyala.");
    }
  }
}