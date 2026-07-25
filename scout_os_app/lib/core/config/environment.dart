class Environment {
  // --- BACKEND API CONFIGURATION (FASTAPI + POSTGRESQL) ---

  /// Base API URL set via --dart-define=API_URL=...
  /// Example dev run: flutter run --dart-define=API_URL=http://10.0.2.2:8080/api/v1
  /// Example prod build: flutter build apk --dart-define=API_URL=https://api.pradigi.id/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://13.212.174.32:8080/api/v1',
  );

  /// Resolve a URL that may be relative (e.g. /api/v1/users/me/avatar/file.jpg)
  /// to a full URL by prepending the API host.
  static String resolveUrl(String url) {
    if (url.startsWith('http') || url.startsWith('data:')) return url;
    // Extract host from apiBaseUrl (strip /api/v1 suffix)
    final host = apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$'), '');
    return '$host$url';
  }

  // --- NETWORK CONFIGURATION ---
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 120000;
  static const bool enableLogging = true; // Set false for production
}
