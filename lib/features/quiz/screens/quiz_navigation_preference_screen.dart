import 'package:flutter/material.dart';

import '../../../core/preferences/quiz_navigation_preferences.dart';
import '../../../core/theme/app_design.dart';

/// Shown once, the first time a user reaches the quiz viewer, to let them
/// pick how they move between questions. Pops with the chosen style once
/// picked — there's no way to dismiss without choosing, since the viewer
/// behind it has nothing meaningful to show without a style yet.
class QuizNavigationPreferenceScreen extends StatelessWidget {
  const QuizNavigationPreferenceScreen({super.key});

  Future<void> _choose(
    BuildContext context,
    QuizNavigationStyle style,
  ) async {
    await QuizNavigationPreferences.setStyle(style);

    if (!context.mounted) return;

    Navigator.of(context).pop(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ScholarIconBadge(icon: Icons.swipe_rounded, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    'How do you want to move between questions?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You can change this anytime in your profile.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.scholarPalette.textMuted,
                        ),
                  ),
                  const SizedBox(height: 28),
                  _StyleOption(
                    icon: Icons.swap_vert_rounded,
                    title: 'Scroll',
                    subtitle: 'All questions in one scrollable list',
                    onTap: () =>
                        _choose(context, QuizNavigationStyle.scroll),
                  ),
                  const SizedBox(height: 14),
                  _StyleOption(
                    icon: Icons.swipe_rounded,
                    title: 'Swipe',
                    subtitle: 'One question at a time, swipe left/right',
                    onTap: () =>
                        _choose(context, QuizNavigationStyle.swipe),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  const _StyleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScholarPanel(
      onTap: onTap,
      child: Row(
        children: [
          ScholarIconBadge(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.scholarPalette.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.scholarPalette.textMuted,
          ),
        ],
      ),
    );
  }
}
