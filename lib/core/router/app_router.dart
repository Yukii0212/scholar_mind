import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
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
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/flashcards',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: '/grades',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),
    ],
  );
}

// Temporary dashboard placeholder
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard coming next'));
  }
}