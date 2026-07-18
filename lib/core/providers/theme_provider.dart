import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scholar_theme.dart';
import '../services/theme_service.dart';

class ThemeNotifier extends StateNotifier<ScholarTheme> {
  ThemeNotifier() : super(ScholarTheme.midnight) {
    _load();
  }

  Future<void> _load() async {
    state = await ThemeService.loadTheme();
  }

  Future<void> setTheme(
      ScholarTheme theme,
      ) async {
    if (theme == state) return;

    state = theme;

    await ThemeService.saveTheme(theme);
  }
}

final themeProvider =
StateNotifierProvider<ThemeNotifier, ScholarTheme>(
      (ref) => ThemeNotifier(),
);