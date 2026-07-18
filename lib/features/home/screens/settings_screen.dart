import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/models/scholar_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_design.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScholarSectionHeader(
                  title: 'Settings',
                  subtitle: 'Personalize ScholarMind across your account',
                ),
                const Gap(16),
                ScholarPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Gap(12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 520;
                          final cards = [
                            _ThemeOption(
                              theme: ScholarTheme.midnight,
                              label: 'Midnight',
                              icon: AppAssets.darkIcon,
                              selected: currentTheme == ScholarTheme.midnight,
                            ),
                            _ThemeOption(
                              theme: ScholarTheme.scholarBlue,
                              label: 'Scholar Blue',
                              icon: AppAssets.scholarBlueIcon,
                              selected:
                                  currentTheme == ScholarTheme.scholarBlue,
                            ),
                            _ThemeOption(
                              theme: ScholarTheme.sakuraPink,
                              label: 'Sakura Pink',
                              icon: AppAssets.sakuraPinkIcon,
                              selected:
                                  currentTheme == ScholarTheme.sakuraPink,
                            ),
                          ];

                          if (isNarrow) {
                            return Column(
                              children: [
                                for (final card in cards) ...[
                                  card,
                                  if (card != cards.last) const Gap(10),
                                ],
                              ],
                            );
                          }

                          return Row(
                            children: [
                              for (final card in cards) ...[
                                Expanded(child: card),
                                if (card != cards.last) const Gap(10),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends ConsumerWidget {
  const _ThemeOption({
    required this.theme,
    required this.label,
    required this.icon,
    required this.selected,
  });

  final ScholarTheme theme;
  final String label;
  final String icon;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.scholarPalette;

    return ScholarPanel(
      padding: const EdgeInsets.all(12),
      onTap: () => ref.read(themeProvider.notifier).setTheme(theme),
      child: Row(
        children: [
          Image.asset(icon, width: 40, height: 40),
          const Gap(12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? palette.brandEnd : palette.textMuted,
          ),
        ],
      ),
    );
  }
}
