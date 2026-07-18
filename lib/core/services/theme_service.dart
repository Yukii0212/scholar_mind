import 'package:shared_preferences/shared_preferences.dart';

import '../models/scholar_theme.dart';

class ThemeService {
  ThemeService._();

  static const _themeKey = 'selected_theme';

  static Future<ScholarTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    return ScholarThemeExtension.fromId(
      prefs.getString(_themeKey),
    );
  }

  static Future<void> saveTheme(
      ScholarTheme theme,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themeKey,
      theme.id,
    );
  }
}