import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/theme_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/models/scholar_theme.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android renders at 60Hz by default even on higher-refresh-rate
  // panels unless the app explicitly opts in — without this, every
  // animation and scroll in the whole app is capped well below what the
  // device can actually do. `kIsWeb` must short-circuit first: `dart:io`'s
  // Platform isn't available on web and touching it there throws before
  // runApp() ever gets called, leaving a blank screen with no error UI.
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }

  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions
        .currentPlatform,
  );

  await dotenv.load(
    fileName: ".env",
  );

  final initialTheme =
  await ThemeService.loadLocalTheme();

  runApp(
    ProviderScope(
      overrides: [
        initialThemeProvider.overrideWithValue(
          initialTheme,
        ),
      ],
      child: const ScholarMindApp(),
    ),
  );
}

class ScholarMindApp extends ConsumerWidget {
  const ScholarMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final scholarTheme = ref.watch(themeProvider);

    ref.watch(authWarmupProvider);

    return MaterialApp.router(
      title: 'ScholarMind',

      theme: AppTheme.scholarBlueLight,

      darkTheme: switch (scholarTheme) {
        ScholarTheme.scholarBlue => AppTheme.scholarBlueDark,
        ScholarTheme.sakuraPink => AppTheme.sakuraPinkDark,
        ScholarTheme.midnight => AppTheme.midnight,
      },

      themeMode: ThemeMode.dark,

      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
