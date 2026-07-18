import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_design.dart';
import '../../../providers/grading/grading_structure_draft_provider.dart';
import '../../dialogs/grading/grading_component_dialog.dart';
import '../component/grading_component_list.dart';

class GradingStructureCard extends ConsumerWidget {
  const GradingStructureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(gradingStructureDraftProvider);
    final total = draft.components.fold<double>(
      0,
      (sum, component) => sum + component.weight,
    );
    final isBalanced = (total - 100).abs() < 0.001;

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScholarSectionHeader(
            title: 'Grading Structure',
            subtitle: draft.components.isEmpty
                ? 'Add components to calculate this course.'
                : '${draft.components.length} components - ${total.toStringAsFixed(0)}% total',
            trailing: _BalanceBadge(isBalanced: isBalanced),
          ),
          const Gap(18),
          if (draft.components.isEmpty)
            const _EmptyStructure()
          else
            GradingComponentList(components: draft.components),
          const Gap(18),
          FilledButton.icon(
            onPressed: () async {
              final name = await showDialog<String>(
                context: context,
                builder: (_) => const GradingComponentDialog(),
              );

              if (name == null) return;

              ref
                  .read(gradingStructureDraftProvider.notifier)
                  .addComponent(name: name);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Component'),
          ),
          const Gap(18),
          _AdvancedControls(
            autoBalance: draft.autoBalance,
            onAutoBalanceChanged: (value) {
              ref
                  .read(gradingStructureDraftProvider.notifier)
                  .setAutoBalance(value);
            },
            onRebalance: () {
              ref
                  .read(gradingStructureDraftProvider.notifier)
                  .balanceDistribution();
            },
            onReset: () {
              ref
                  .read(gradingStructureDraftProvider.notifier)
                  .resetDistribution();
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyStructure extends StatelessWidget {
  const _EmptyStructure();

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.46),
        border: Border.all(color: palette.stroke),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const ScholarIconBadge(
            icon: Icons.account_tree_outlined,
            size: 56,
          ),
          const Gap(16),
          Text(
            'No components yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Gap(8),
          Text(
            'Start with items like Assignment, Midterm, Final Exam, or Project.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedControls extends StatelessWidget {
  const _AdvancedControls({
    required this.autoBalance,
    required this.onAutoBalanceChanged,
    required this.onRebalance,
    required this.onReset,
  });

  final bool autoBalance;
  final ValueChanged<bool> onAutoBalanceChanged;
  final VoidCallback onRebalance;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.panelStrong.withValues(alpha: 0.5),
        border: Border.all(color: palette.stroke),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ScholarIconBadge(
                icon: Icons.tune_rounded,
                size: 34,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Balance',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'Keep component weights aligned to 100%.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoBalance,
                onChanged: onAutoBalanceChanged,
              ),
            ],
          ),
          if (!autoBalance) ...[
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRebalance,
                    icon: const Icon(Icons.balance_rounded),
                    label: const Text('Rebalance'),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({
    required this.isBalanced,
  });

  final bool isBalanced;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isBalanced ? palette.success : palette.warning)
            .withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isBalanced ? 'Balanced' : 'Review',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isBalanced ? palette.success : palette.warning,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
