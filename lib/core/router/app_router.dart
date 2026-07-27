import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/countdown/screens/countdown_screen.dart';
import '../../features/data_sharing/screens/export_library_screen.dart';
import '../../features/data_sharing/screens/import_library_screen.dart';
import '../../features/data_sharing/screens/import_share_link_screen.dart';
import '../../features/data_sharing/screens/share_hub_screen.dart';
import '../../features/flashcards/screens/flashcard_library_screen.dart';
import '../../features/grades/screens/home/grade_home_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/profile_screen.dart';
import '../../features/home/screens/appearance_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/quiz/screens/quiz_library_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/study_streak/screens/study_streak_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;

      final isOnSplash = location == '/splash';
      final isOnLogin = location == '/login';

      // Always allow the splash screen to display.
      if (isOnSplash) {
        return null;
      }

      // Guests may only access the login screen.
      if (!isLoggedIn && !isOnLogin) {
        return '/login';
      }

      // Logged-in users should not return to the login screen.
      if (isLoggedIn && isOnLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: '/notes',
            builder: (context, state) => const NotesScreen(),
          ),
          GoRoute(
            path: '/flashcards',
            builder: (context, state) => const FlashcardLibraryScreen(),
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) => const QuizLibraryScreen(),
          ),
          GoRoute(
            path: '/grades',
            builder: (context, state) => const GradeHomeScreen(),
          ),
          GoRoute(
            path: '/study-streak',
            builder: (context, state) => const StudyStreakScreen(),
          ),
          GoRoute(
            path: '/countdown',
            builder: (context, state) => const CountdownScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
            const AppearanceScreen(),
          ),
          GoRoute(
            path: '/share',
            builder: (context, state) =>
            const ShareHubScreen(),
          ),
          GoRoute(
            path: '/export',
            builder: (context, state) =>
            const ExportLibraryScreen(),
          ),
          GoRoute(
            path: '/import',
            builder: (context, state) =>
            const ImportLibraryScreen(),
          ),
          GoRoute(
            path: '/import/share/:shareId',
            builder: (context, state) =>
                ImportShareLinkScreen(
                  shareId: state.pathParameters['shareId']!,
                ),
          ),
        ],
      ),
    ],
  );

  ref.listen(authStateProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
}
