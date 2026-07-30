import 'package:shared_preferences/shared_preferences.dart';

enum QuizNavigationStyle {
  scroll,
  swipe,
}

class QuizNavigationPreferences {
  QuizNavigationPreferences._();

  static const _styleKey = 'quizNavigationStyle';

  /// Null means the user hasn't chosen yet — that's what gates showing
  /// the one-time onboarding picker.
  static Future<QuizNavigationStyle?> getStyle() async {
    final preferences = await SharedPreferences.getInstance();

    return switch (preferences.getString(_styleKey)) {
      'scroll' => QuizNavigationStyle.scroll,
      'swipe' => QuizNavigationStyle.swipe,
      _ => null,
    };
  }

  static Future<void> setStyle(QuizNavigationStyle style) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_styleKey, style.name);
  }
}
