import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:scout_os_app/core/config/environment.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';
import 'package:scout_os_app/features/home/data/models/training_question.dart';

/// Training Service - Handles API calls to FastAPI backend for training content
/// 
/// Architecture: Flutter App -> FastAPI Backend -> PostgreSQL
/// Base URL: Environment.apiBaseUrl (Production: https://khasyaraka-890949539640.asia-southeast2.run.app/api/v1)
class TrainingService {
  /// Fetch a specific level by ID
  /// 
  /// Endpoint: GET /api/v1/training/levels/{levelId}
  /// 
  /// Throws:
  /// - Exception with 404 message if level not found
  /// - Exception with timeout message if request times out
  Future<Map<String, dynamic>> fetchLevelById(String levelId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/levels/$levelId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout: Server tidak merespons dalam ${Environment.connectTimeout}ms'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
            
      } else if (response.statusCode == 404) {
        throw Exception('404: Level "$levelId" not found or inactive');
        
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Database atau Redis bermasalah');
        
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
    } on http.ClientException catch (e) {
      throw Exception('NetworkException: Tidak dapat terhubung ke server - ${e.message}');
      
    } on FormatException catch (e) {
      throw Exception('JSON Parse Error: Response dari server tidak valid - ${e.message}');
      
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Fetch all levels in a unit
  /// 
  /// Endpoint: GET /api/v1/training/units/{unitId}/levels
  /// 
  /// Throws:
  /// - Exception with 404 message if unit not found
  /// - Exception with timeout message if request times out
  Future<List<Map<String, dynamic>>> fetchLevelsByUnit(String unitId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/units/$unitId/levels');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout: Server tidak merespons dalam ${Environment.connectTimeout}ms'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final levelsJson = data['levels'] as List<dynamic>? ?? [];
        
        return levelsJson
            .map((level) => level as Map<String, dynamic>)
            .toList();
            
      } else if (response.statusCode == 404) {
        throw Exception('404: Unit "$unitId" not found or inactive');
        
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Database atau Redis bermasalah');
        
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
    } on http.ClientException catch (e) {
      throw Exception('NetworkException: Tidak dapat terhubung ke server - ${e.message}');
      
    } on FormatException catch (e) {
      throw Exception('JSON Parse Error: Response dari server tidak valid - ${e.message}');
      
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Fetch questions for a specific unit (all questions from all levels in unit)
  /// 
  /// Endpoint: GET /api/v1/training/units/{unitId}/questions
  /// 
  /// Throws:
  /// - Exception with 404 message if unit not found
  /// - Exception with timeout message if request times out
  /// - Exception with connection message if network error
  Future<List<TrainingQuestion>> fetchQuestionsByUnit(String unitId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/units/$unitId/questions');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout: Server tidak merespons dalam ${Environment.connectTimeout}ms'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questionsJson = data['questions'] as List<dynamic>;
        
        if (questionsJson.isEmpty) {
          return []; // Empty list, bukan error
        }
        
        return questionsJson
            .map((q) => TrainingQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
            
      } else if (response.statusCode == 404) {
        throw Exception('404: Unit "$unitId" not found or inactive');
        
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Database atau Redis bermasalah');
        
      } else if (response.statusCode == 503) {
        throw Exception('Service Unavailable (503): Server sedang maintenance');
        
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
    } on http.ClientException catch (e) {
      throw Exception('NetworkException: Tidak dapat terhubung ke server - ${e.message}');
      
    } on FormatException catch (e) {
      throw Exception('JSON Parse Error: Response dari server tidak valid - ${e.message}');
      
    } on Exception {
      // Re-throw exception yang sudah kita buat
      rethrow;
      
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Fetch questions for a specific level
  /// 
  /// Endpoint: GET /api/v1/training/levels/{levelId}/questions
  /// 
  /// Throws:
  /// - Exception with 404 message if level not found
  /// - Exception with timeout message if request times out
  /// - Exception with connection message if network error
  Future<List<TrainingQuestion>> fetchQuestions(String levelId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/levels/$levelId/questions');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout: Server tidak merespons dalam ${Environment.connectTimeout}ms'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questionsJson = data['questions'] as List<dynamic>;
        
        if (questionsJson.isEmpty) {
          return []; // Empty list, bukan error
        }
        
        // Parse questions
        final allQuestions = questionsJson
            .map((q) => TrainingQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
        
        // DEFENSIVE FILTERING: Ensure we only return questions for this specific levelId
        // This prevents bugs where backend returns all questions
        // CRITICAL: Use STRICT EQUALITY (==) not contains() or startsWith()
        final filteredQuestions = allQuestions
            .where((q) => q.levelId.trim() == levelId.trim())
            .toList();
        
        // DEBUG LOGGING: Help diagnose data leak issues
        debugPrint('🔍 Fetching questions for Level: $levelId');
        debugPrint('   📊 Backend returned: ${allQuestions.length} total questions');
        debugPrint('   ✅ After filtering: ${filteredQuestions.length} questions match levelId');
        if (allQuestions.isNotEmpty) {
          final uniqueLevelIds = allQuestions.map((q) => q.levelId).toSet();
          debugPrint('   📋 Found levelIds in response: ${uniqueLevelIds.join(", ")}');
          if (filteredQuestions.isNotEmpty) {
            debugPrint('   ✅ Sample filtered questions:');
            filteredQuestions.take(3).forEach((q) {
              debugPrint('      - QID: ${q.id} | LevelID: ${q.levelId} | Order: ${q.order}');
            });
          }
        }
        
        if (filteredQuestions.isEmpty && allQuestions.isNotEmpty) {
          // Backend returned questions but none match the levelId
          // This indicates a backend bug, but we handle it gracefully
          final uniqueLevelIds = allQuestions.map((q) => q.levelId).toSet();
          throw Exception('Backend returned ${allQuestions.length} questions but none match level "$levelId". Found levelIds: ${uniqueLevelIds.join(", ")}');
        }
        
        // CRITICAL: Sort by order field to maintain exact sequence from database
        // Backend already orders by order field, but we ensure it here as well
        filteredQuestions.sort((a, b) => a.order.compareTo(b.order));
        
        return filteredQuestions;
            
      } else if (response.statusCode == 404) {
        throw Exception('404: Level "$levelId" not found or inactive');
        
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Database atau Redis bermasalah');
        
      } else if (response.statusCode == 503) {
        throw Exception('Service Unavailable (503): Server sedang maintenance');
        
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
    } on http.ClientException catch (e) {
      throw Exception('NetworkException: Tidak dapat terhubung ke server - ${e.message}');
      
    } on FormatException catch (e) {
      throw Exception('JSON Parse Error: Response dari server tidak valid - ${e.message}');
      
    } on Exception {
      // Re-throw exception yang sudah kita buat
      rethrow;
      
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Submit progress after completing a level
  /// 
  /// Endpoint: POST /api/v1/training/progress/submit
  /// 
  /// ✅ CRITICAL: Backend calculates XP from questions.xp (server-side)
  /// Client sends correct_question_ids so backend can calculate XP accurately
  /// 
  /// ✅ CRITICAL: Requires JWT authentication (Authorization header)
  Future<Map<String, dynamic>> submitProgress({
    required String levelId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required List<String> correctQuestionIds, // ✅ NEW: List of question IDs answered correctly
    int timeSpentSeconds = 0,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/progress/submit');
      
      // ✅ CRITICAL FIX: Get JWT token for authentication
      final token = await ApiDioProvider.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      // ✅ CRITICAL: Add Authorization header if token exists
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ [SUBMIT_PROGRESS] Authorization header added: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      } else {
        debugPrint('⚠️ [SUBMIT_PROGRESS] WARNING: No JWT token found! Request will fail with 401 Unauthorized.');
        throw Exception('Not authenticated: JWT token not found. Please login again.');
      }
      
      debugPrint('📤 [SUBMIT_PROGRESS] Sending request to: $url');
      debugPrint('📤 [SUBMIT_PROGRESS] Payload: level_id=$levelId, score=$score, correct_answers=$correctAnswers, total_questions=$totalQuestions');
      debugPrint('📤 [SUBMIT_PROGRESS] Correct question IDs: $correctQuestionIds');
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'level_id': levelId,
          'score': score,
          'total_questions': totalQuestions,
          'correct_answers': correctAnswers,
          'correct_question_ids': correctQuestionIds, // ✅ NEW: Send list of correct question IDs
          'time_spent_seconds': timeSpentSeconds,
        }),
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      debugPrint('📥 [SUBMIT_PROGRESS] Response status: ${response.statusCode}');
      debugPrint('📥 [SUBMIT_PROGRESS] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        // ✅ CRITICAL DEBUG: Log XP values from response
        final xpEarned = responseData['xp_earned'] as int? ?? 0;
        final totalXp = responseData['total_xp'] as int? ?? 0;
        debugPrint('✅ [SUBMIT_PROGRESS] Response parsed: xp_earned=$xpEarned, total_xp=$totalXp');
        
        return responseData;
      } else if (response.statusCode == 401) {
        debugPrint('❌ [SUBMIT_PROGRESS] 401 Unauthorized - Token may be invalid or expired');
        throw Exception('Unauthorized: Please login again (HTTP 401)');
      } else {
        debugPrint('❌ [SUBMIT_PROGRESS] HTTP ${response.statusCode}: ${response.reasonPhrase}');
        debugPrint('   Response body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('❌ [SUBMIT_PROGRESS] Error: $e');
      rethrow;
    }
  }
  /// Fetch learning path for a section
  /// 
  /// Endpoint: GET /api/v1/training/sections/{sectionId}/path
  /// 
  /// Throws:
  /// - Exception with 404 if section not found
  /// - Exception with timeout if request times out
  /// - Exception with connection error if network fails
  /// 
  /// ✅ CRITICAL: Requires JWT authentication for user-specific progress
  Future<Map<String, dynamic>> fetchLearningPath(String sectionId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/sections/$sectionId/path');
      
      // ✅ Get JWT token for user-specific progress
      final token = await ApiDioProvider.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      // Add Authorization header if token exists
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ [FETCH_PATH] Authorization header added for user progress');
      } else {
        debugPrint('⚠️ [FETCH_PATH] No token - returning generic (non-user) progress');
      }
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout: Server tidak merespons'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
        
      } else if (response.statusCode == 404) {
        throw Exception('404: Section "$sectionId" tidak ditemukan atau tidak aktif');
        
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Database atau Redis bermasalah');
        
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
    } on http.ClientException catch (e) {
      throw Exception('NetworkException: Tidak dapat terhubung ke server - ${e.message}');
      
    } on FormatException catch (e) {
      throw Exception('JSON Parse Error: Response tidak valid - ${e.message}');
      
    } on Exception {
      rethrow;
      
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Fetch all available sections
  /// 
  /// Endpoint: GET /api/v1/training/sections
  /// 
  /// Returns: List of sections with id, title, order
  Future<List<Map<String, dynamic>>> fetchSections() async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/training/sections');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Environment.connectTimeout),
        onTimeout: () => throw Exception('Connection timeout: Server tidak merespons'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sectionsJson = data['sections'] as List<dynamic>? ?? [];
        
        return sectionsJson
            .map((s) => s as Map<String, dynamic>)
            .toList();
        
      } else if (response.statusCode == 500) {
        throw Exception('Server Error (500): Database atau Redis bermasalah');
        
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
    } on http.ClientException catch (e) {
      throw Exception('NetworkException: Tidak dapat terhubung ke server - ${e.message}');
      
    } on FormatException catch (e) {
      throw Exception('JSON Parse Error: Response tidak valid - ${e.message}');
      
    } on Exception {
      rethrow;
      
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }
}

