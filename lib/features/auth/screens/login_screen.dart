import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'ScholarMind',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const Gap(8),
              Text(
                'Your AI-powered study companion.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Sign-in failed. Please try again.',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              FilledButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () => ref
                    .read(authNotifierProvider.notifier)
                    .signInWithGoogle(),
                icon: authState.isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.login),
                label: const Text('Continue with Google'),
              ),
              const Gap(48),
            ],
          ),
        ),
      ),
    );
  }
}