import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// LocalCacheService - Hive-based cache for SWR pattern
/// 
/// Provides instant data loading from local storage while
/// background revalidation fetches fresh data from API.
/// 
/// Cached data types:
/// - User Profile (XP, Streak)
/// - Training Path (Sections, Units structure)
/// - Leaderboard (top users, my rank)
class LocalCacheService {
  static const String _boxName = 'app_cache';
  static const String _metaBoxName = 'cache_meta';
  
  static Box? _cacheBox;
  static Box? _metaBox;
  static bool _isInitialized = false;
  
  /// Cache keys
  static const String keyUserProfile = 'user_profile';
  static const String keySections = 'training_sections';
  static const String keyUnitsPrefix = 'training_units_'; // + sectionId
  static const String keyLeaderboard = 'leaderboard';
  static const String keyProgress = 'user_progress';
  
  /// Default TTL values
  static const Duration defaultTtl = Duration(hours: 24);
  static const Duration shortTtl = Duration(minutes: 5);
  static const Duration longTtl = Duration(days: 7);
  
  /// Initialize Hive and open cache boxes
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(_boxName);
      _metaBox = await Hive.openBox(_metaBoxName);
      _isInitialized = true;
      debugPrint('✅ [CACHE] LocalCacheService initialized');
    } catch (e) {
      debugPrint('❌ [CACHE] Failed to initialize Hive: $e');
      // Continue without cache - app will still work via API
    }
  }
  
  /// Get cached data by key
  /// Returns null if not found or expired
  static Future<T?> get<T>(String key) async {
    if (!_isInitialized || _cacheBox == null) return null;
    
    try {
      // Check if expired
      final expiresAt = _metaBox?.get('${key}_expires') as int?;
      if (expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt) {
        debugPrint('⏰ [CACHE] Key "$key" expired, returning null');
        return null;
      }
      
      final data = _cacheBox?.get(key);
      if (data == null) return null;
      
      // Handle JSON string stored data
      if (data is String && T != String) {
        try {
          final decoded = jsonDecode(data);
          debugPrint('📦 [CACHE] Retrieved "$key" from cache');
          return decoded as T;
        } catch (e) {
          return data as T;
        }
      }
      
      debugPrint('📦 [CACHE] Retrieved "$key" from cache');
      return data as T;
    } catch (e) {
      debugPrint('⚠️ [CACHE] Error getting "$key": $e');
      return null;
    }
  }
  
  /// Store data with optional TTL
  static Future<void> put<T>(String key, T value, {Duration? ttl}) async {
    if (!_isInitialized || _cacheBox == null) return;
    
    try {
      // Store data as JSON string for complex types
      final dataToStore = (value is Map || value is List) 
          ? jsonEncode(value) 
          : value;
      
      await _cacheBox?.put(key, dataToStore);
      
      // Store expiration timestamp
      final effectiveTtl = ttl ?? defaultTtl;
      final expiresAt = DateTime.now().add(effectiveTtl).millisecondsSinceEpoch;
      await _metaBox?.put('${key}_expires', expiresAt);
      
      debugPrint('💾 [CACHE] Stored "$key" (expires in ${effectiveTtl.inMinutes}min)');
    } catch (e) {
      debugPrint('⚠️ [CACHE] Error storing "$key": $e');
    }
  }
  
  /// Delete specific key
  static Future<void> delete(String key) async {
    if (!_isInitialized || _cacheBox == null) return;
    
    try {
      await _cacheBox?.delete(key);
      await _metaBox?.delete('${key}_expires');
      debugPrint('🗑️ [CACHE] Deleted "$key"');
    } catch (e) {
      debugPrint('⚠️ [CACHE] Error deleting "$key": $e');
    }
  }
  
  /// Clear all cached data (for logout)
  static Future<void> clear() async {
    if (!_isInitialized) return;
    
    try {
      await _cacheBox?.clear();
      await _metaBox?.clear();
      debugPrint('🧹 [CACHE] All cache cleared');
    } catch (e) {
      debugPrint('⚠️ [CACHE] Error clearing cache: $e');
    }
  }
  
  /// Check if key exists and is not expired
  static Future<bool> has(String key) async {
    final value = await get<dynamic>(key);
    return value != null;
  }
  
  /// Get cache age in seconds (for debugging)
  static Future<int?> getAge(String key) async {
    if (!_isInitialized || _metaBox == null) return null;
    
    final storedAt = _metaBox?.get('${key}_stored') as int?;
    if (storedAt == null) return null;
    
    return (DateTime.now().millisecondsSinceEpoch - storedAt) ~/ 1000;
  }
}
