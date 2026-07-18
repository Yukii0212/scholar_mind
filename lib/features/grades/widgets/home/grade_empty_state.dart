import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_design.dart';

class GradeEmptyState extends StatelessWidget {
  const GradeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: ScholarPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ScholarIconBadge(
                  icon: Icons.bar_chart_rounded,
                  size: 58,
                ),
                const Gap(18),
                Text(
                  'No semester found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Text(
                  'Create your first semester from the + menu to start tracking your grades.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.scholarPalette.textMuted,
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
