import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuizLocalCacheService {

  const QuizLocalCacheService();

  static const _attemptKey =
      'active_quiz_attempt';

  Future<void> save(
      Map<String, dynamic> json,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _attemptKey,
      jsonEncode(json),
    );
  }

  Future<Map<String, dynamic>?>
  load() async {

    final prefs =
    await SharedPreferences.getInstance();

    final raw =
    prefs.getString(_attemptKey);

    if (raw == null) {
      return null;
    }

    return jsonDecode(raw)
    as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      _attemptKey,
    );
  }
}