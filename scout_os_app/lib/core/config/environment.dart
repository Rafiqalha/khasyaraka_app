class Environment {
  // --- BACKEND API CONFIGURATION (FASTAPI + POSTGRESQL) ---
  
  // Production API URL (Cloud Run)
  // - Production: https://khasyaraka-890949539640.asia-southeast2.run.app/api/v1
  // - Development: http://192.168.1.18:8000/api/v1 (uncomment for local dev)
  static const String apiBaseUrl = "https://khasyaraka-v2-890949539640.asia-southeast2.run.app/api/v1"; 

  // --- NETWORK CONFIGURATION ---
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const bool enableLogging = true; // Set false for production
}