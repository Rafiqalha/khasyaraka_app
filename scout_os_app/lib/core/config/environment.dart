class Environment {
  // --- BACKEND API CONFIGURATION (FASTAPI + POSTGRESQL) ---

  // Production API URL (Cloud Run)
  // - Production: https://pradigi-890949539640.asia-southeast2.run.app/api/v1
  // - Development: http://192.168.100.95:8000/api/v1 (local dev)
  // static const String apiBaseUrl =
  //     "https://pradigi-v2-890949539640.asia-southeast2.run.app/api/v1";
  static const String apiBaseUrl =
      "http://127.0.0.1:8080/api/v1"; // LOCALHOST FOR DESKTOP

  /// Resolve a URL that may be relative (e.g. /api/v1/users/me/avatar/file.jpg)
  /// to a full URL by prepending the API host.
  static String resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    // Extract host from apiBaseUrl (strip /api/v1 suffix)
    final host = apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
    return '$host$url';
  }

  // --- NETWORK CONFIGURATION ---
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const bool enableLogging = true; // Set false for production
}
