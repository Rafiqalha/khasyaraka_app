/// Survival Repository - OFFLINE ONLY
///
/// This repository is NO LONGER used for API calls.
/// All sensor data is handled directly by the SurvivalToolsController.
///
/// This file is kept for compatibility, but all methods are disabled
/// or return local-only data.

import 'package:dio/dio.dart';
import 'package:scout_os_app/core/network/api_dio_provider.dart';

class SurvivalRepository {
  SurvivalRepository({Dio? dio}) : _dio = dio ?? ApiDioProvider.getDio();

  final Dio _dio;

  /// DEPRECATED: All sensor data is now handled locally by SurvivalToolsController
  /// This method is no longer used and will throw a deprecation error.
  @deprecated
  Future<void> fetchMastery() async {
    throw UnsupportedError(
      'Survival module is now 100% OFFLINE. '
      'Use SurvivalToolsController to access sensor data directly. '
      'No API calls to backend needed.',
    );
  }

  /// DEPRECATED: XP/Level system removed. Survival is now a pure utility toolkit.
  @deprecated
  Future<void> recordAction({
    required String toolType,
    int xpGained = 10,
    Map<String, dynamic>? metadata,
  }) async {
    throw UnsupportedError(
      'Survival module is now 100% OFFLINE. '
      'XP and levels are no longer tracked. '
      'Use SurvivalToolsController to access sensor data directly.',
    );
  }
}
