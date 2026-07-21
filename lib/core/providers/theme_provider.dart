import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../models/scholar_theme.dart';
import '../services/theme_service.dart';

class ThemeNotifier extends StateNotifier<ScholarTheme> {
  ThemeNotifier() : super(ScholarTheme.midnight);

  String? _userId;

  Future<void> loadForUser(String? userId) async {
    _userId = userId;
    final theme = await ThemeService.loadTheme(userId: userId);
    if (mounted && _userId == userId) {
      state = theme;
    }
  }

  Future<void> setTheme(
    ScholarTheme theme,
  ) async {
    if (theme == state) return;

    state = theme;

    await ThemeService.saveTheme(theme, userId: _userId);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ScholarTheme>(
  (ref) {
    final notifier = ThemeNotifier();
    notifier.loadForUser(ref.read(authStateProvider).valueOrNull?.uid);

    ref.listen(authStateProvider, (_, next) {
      notifier.loadForUser(next.valueOrNull?.uid);
    });

    return notifier;
  },
);
