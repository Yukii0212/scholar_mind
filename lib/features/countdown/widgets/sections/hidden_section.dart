import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../providers/countdown_provider.dart';
import '../countdown_actions.dart';
import '../countdown_card.dart';
import '../countdown_navigation.dart';

class HiddenSection extends ConsumerWidget {
  const HiddenSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownsProvider);
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return countdowns.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final hidden = items
            .where((item) => item.isHidden)
            .toList();

        if (hidden.isEmpty) {
          return const SizedBox.shrink();
        }

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          title: Text(
            'Hidden (${hidden.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            ...hidden.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CountdownCard(
                  item: item,
                  onToggle: userId == null
                      ? null
                      : (completed) => ref
                      .read(countdownRepositoryProvider)
                      .markCompleted(
                    userId: userId,
                    countdownId: item.id,
                    completed: completed,
                  ),
                  onEdit: userId == null
                      ? null
                      : () => CountdownNavigation.openCrud(
                    context,
                    initial: item,
                  ),
                  onHide: userId == null
                      ? null
                      : () => ref
                      .read(countdownRepositoryProvider)
                      .setHidden(
                    userId: userId,
                    countdownId: item.id,
                    hidden: false,
                  ),
                  onDelete: userId == null
                      ? null
                      : () => CountdownActions.delete(
                    context,
                    ref,
                    userId,
                    item,
                  ),
                ),
              ),
            ),
            const Gap(20),
          ],
        );
      },
    );
  }
}