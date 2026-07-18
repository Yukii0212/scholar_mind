import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_design.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAction = ref.watch(authControllerProvider);
    final palette = context.scholarPalette;

    return Scaffold(
      body: ScholarScaffoldBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    Container(
                      width: 138,
                      height: 138,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: palette.brandEnd.withValues(alpha: 0.5),
                        ),
                        gradient: palette.panelGradient,
                        boxShadow: [
                          BoxShadow(
                            color: palette.brandStart.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(scholarThemeIconAsset(context)),
                      ),
                    ),
                    const Gap(24),
                    const ScholarBrand(logoSize: 34),
                    const Gap(8),
                    Text(
                      'Organize. Understand. Succeed.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                    const Gap(28),
                    ScholarPanel(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome back',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Gap(8),
                          Text(
                            'Continue into your AI-powered study companion.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: palette.textMuted,
                                    ),
                          ),
                          const Gap(18),
                          if (authAction.hasError) ...[
                            Text(
                              'Sign-in failed. Please try again.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const Gap(12),
                          ],
                          FilledButton.icon(
                            onPressed: authAction.isLoading
                                ? null
                                : () => ref
                                    .read(authControllerProvider.notifier)
                                    .signInWithGoogle(),
                            icon: authAction.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: const Text('Continue with Google'),
                          ),
                        ],
                      ),
                    ),
                    const Gap(18),
                    const ScholarIllustration(size: 156),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
