import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/grades/screens/home/grade_home_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/quiz/screens/quiz_library_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/home';
      return null;
    },
    routes: [
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
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) => const QuizLibraryScreen(),
          ),
          GoRoute(
            path: '/grades',
            builder: (context, state) => const GradeHomeScreen(),
          ),
        ],
      ),
    ],
  );

  ref.listen(authStateProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
}

// Temporary dashboard placeholder
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard coming next'));
  }
}
