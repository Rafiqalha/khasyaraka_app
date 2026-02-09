import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:scout_os_app/core/services/local_cache_service.dart';

/// Base Repository with Stale-While-Revalidate (SWR) Pattern
/// 
/// Generic implementation for robust offline-first data fetching.
/// 
/// T: The type of data model to return.
abstract class BaseRepository<T> {
  
  /// Fetch data with SWR strategy
  /// 
  /// 1. Yields cached data immediately (if available)
  /// 2. Fetches fresh data from API silently
  /// 3. Yields fresh data and updates cache
  /// 4. Handles errors gracefully (keeps showing cached data)
  Stream<T> fetchData({
    required String cacheKey,
    required Future<T> Function() apiCall,
    required T Function(dynamic json) fromJson,
    Duration? ttl,
  }) async* {
    T? cachedData;
    
    // 1. Try to load from cache
    try {
      final dynamic json = await LocalCacheService.get(cacheKey);
      if (json != null) {
        cachedData = fromJson(json);
        if (cachedData != null) {
          debugPrint('📦 [SWR] Yielding cached data for $cacheKey');
          yield cachedData;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [SWR] Cache read error for $cacheKey: $e');
    }
    
    // 2. Fetch fresh data from API
    try {
      debugPrint('cloud_queue [SWR] Fetching fresh data for $cacheKey...');
      
      // Add aggressive timeout for Cold Start handling (e.g., 5-10 seconds for initial load)
      final freshData = await apiCall().timeout(const Duration(seconds: 10));
      
      // 3. Yield fresh data
      debugPrint('✅ [SWR] Yielding fresh data for $cacheKey');
      yield freshData;
      
      // 4. Update Cache (Fire-and-forget to avoid blocking UI)
      final dynamic jsonToStore = (freshData as dynamic).toJson(); // Assuming T has toJson() or we handle it
      // Note: Generic T might not have toJson visible here without constraint, 
      // but in Dart dynamic dispatch works. Or we can pass a toJson serializer.
      // For simplicity in this architecture, we assume models serialize to Map/List standard JSON.
      
      LocalCacheService.put(cacheKey, jsonToStore, ttl: ttl).catchError((e) {
        debugPrint('⚠️ [SWR] Cache write error for $cacheKey: $e');
      });
      
    } on TimeoutException {
      debugPrint('⏱️ [SWR] API Timeout for $cacheKey - Keeping stale data');
      // Do nothing, stream ends, UI keeps stale data if available
      // If no cache was yielded, UI handles "no data" state via ViewModel
      if (cachedData == null) {
        throw TimeoutException('Connection timed out. Please check your internet.');
      }
    } catch (e) {
      debugPrint('❌ [SWR] API Error for $cacheKey: $e');
      // If we have cached data, suppress the error to the UI (Offline-First)
      // Only throw if we have NOTHING to show
      if (cachedData == null) {
        rethrow;
      }
    }
  }
}
