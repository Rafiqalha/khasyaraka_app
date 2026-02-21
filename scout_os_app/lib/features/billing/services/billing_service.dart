import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class BillingService {
  final Dio _dio = ApiDioProvider.getDio();

  /// Fetch user's current subscription status
  Future<Map<String, dynamic>> fetchSubscriptionStatus() async {
    try {
      final response = await _dio.get('/user/subscription');
      return response.data;
    } catch (e) {
      debugPrint('❌ [BILLING_SERVICE] Fetch error: $e');
      rethrow;
    }
  }

  /// Request a subscription upgrade
  Future<Map<String, dynamic>> upgradeSubscription({
    required String tier,
    required String paymentReference,
    String billingProvider = 'manual',
    int durationDays = 30,
  }) async {
    try {
      final response = await _dio.post(
        '/user/subscription/upgrade',
        data: {
          'tier': tier,
          'payment_reference': paymentReference,
          'billing_provider': billingProvider,
          'duration_days': durationDays,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ [BILLING_SERVICE] Upgrade error: $e');
      rethrow;
    }
  }

  /// Request a subscription renewal
  Future<Map<String, dynamic>> renewSubscription({
    required String paymentReference,
    int durationDays = 30,
  }) async {
    try {
      final response = await _dio.post(
        '/user/subscription/renew',
        data: {
          'payment_reference': paymentReference,
          'duration_days': durationDays,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('❌ [BILLING_SERVICE] Renew error: $e');
      rethrow;
    }
  }
}
