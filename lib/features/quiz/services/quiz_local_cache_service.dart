import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuizLocalCacheService {
  const QuizLocalCacheService();

  static const _legacyAttemptKey = 'active_quiz_attempt';

  static String _attemptKey(String userId) {
    return 'active_quiz_attempt_$userId';
  }

  Future<void> saveAttempt({
    required String userId,
    required Map<String, dynamic> json,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _attemptKey(userId),
      jsonEncode(json),
    );

    await prefs.remove(_legacyAttemptKey);
  }

  Future<Map<String, dynamic>?> loadCurrentAttempt({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_attemptKey(userId));

    if (raw == null) {
      return null;
    }

    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearCurrentAttempt({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_attemptKey(userId));
    await prefs.remove(_legacyAttemptKey);
  }
}
