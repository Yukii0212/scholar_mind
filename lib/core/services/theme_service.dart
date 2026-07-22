import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scholar_theme.dart';

class ThemeService {
  ThemeService._();

  static const _themeKey = 'selected_theme';

  static Future<ScholarTheme> loadLocalTheme() async {
    final prefs = await SharedPreferences.getInstance();

    return ScholarThemeExtension.fromId(
      prefs.getString(_themeKey),
    );
  }

  static Future<ScholarTheme> loadTheme({
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final localTheme =
    await loadLocalTheme();

    if (userId == null) {
      return localTheme;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('app')
          .get();

      final remoteTheme = snapshot.data()?[_themeKey] as String?;
      if (remoteTheme == null) {
        return localTheme;
      }

      final theme = ScholarThemeExtension.fromId(remoteTheme);

      await prefs.setString(_themeKey, theme.id);
      return theme;
    } catch (_) {
      return localTheme;
    }
  }

  static Future<void> saveTheme(
    ScholarTheme theme, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeKey,
      theme.id,
    );

    if (userId == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('app')
          .set(
        {
          _themeKey: theme.id,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
