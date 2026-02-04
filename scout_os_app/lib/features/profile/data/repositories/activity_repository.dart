import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// ActivityRepository – real activity log (NO MOCK DATA).
///
/// Stores active dates per user in SharedPreferences:
/// - Key: `activity_log_$userId`
/// - Value: JSON array of "YYYY-MM-DD" strings.
///
/// Streak is computed from consecutive days ending today.
class ActivityRepository {
  static const String _activityLogPrefix = 'activity_log_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns today's date as YYYY-MM-DD.
  static String _todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// If today is not in the log, append it. Idempotent.
  Future<void> logDailyActivity(String userId) async {
    final prefs = await _getPrefs();
    final key = '$_activityLogPrefix$userId';
    final raw = prefs.getString(key);
    final List<String> dates = raw != null && raw.isNotEmpty
        ? (jsonDecode(raw) as List<dynamic>).map((e) => e.toString()).toList()
        : [];

    final today = _todayString();
    if (dates.contains(today)) return;

    dates.add(today);
    dates.sort();
    await prefs.setString(key, jsonEncode(dates));
  }

  /// Returns the list of active dates (YYYY-MM-DD) for the user.
  Future<List<String>> getActivityLog(String userId) async {
    final prefs = await _getPrefs();
    final key = '$_activityLogPrefix$userId';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e.toString()).toList();
  }

  /// Computes streak = number of consecutive days ending today.
  /// Dates must be "YYYY-MM-DD" and sorted.
  static int getStreakFromLog(List<String> dates) {
    if (dates.isEmpty) return 0;
    final today = _todayString();
    final set = dates.toSet();
    if (!set.contains(today)) return 0;

    int streak = 0;
    DateTime d = DateTime.parse(today);
    while (true) {
      final s =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (!set.contains(s)) break;
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
