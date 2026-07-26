import 'package:shared_preferences/shared_preferences.dart';

class ExportPreferences {
  ExportPreferences._();

  static const _swipeHintKey =
      'hasDismissedExportCartSwipeHint';

  static Future<bool> shouldShowSwipeHint() async {
    final preferences =
    await SharedPreferences.getInstance();

    return !(preferences.getBool(_swipeHintKey) ?? false);
  }

  static Future<void> dismissSwipeHint() async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.setBool(
      _swipeHintKey,
      true,
    );
  }

  static Future<void> enableSwipeHint() async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.setBool(
      _swipeHintKey,
      false,
    );
  }
}