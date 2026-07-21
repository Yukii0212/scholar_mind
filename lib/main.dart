import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/models/scholar_theme.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: ScholarMindApp()));
}

class ScholarMindApp extends ConsumerWidget {
  const ScholarMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final scholarTheme = ref.watch(themeProvider);

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
