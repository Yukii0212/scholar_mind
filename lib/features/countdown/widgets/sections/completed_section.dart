import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../providers/countdown_provider.dart';
import '../../screens/countdown_crud_screen.dart';
import '../countdown_actions.dart';
import '../countdown_card.dart';
import '../countdown_navigation.dart';

class CompletedSection extends ConsumerWidget {
  const CompletedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownsProvider);
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    return countdowns.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final completed = items
            .where(
              (item) => item.isCompleted && !item.isHidden,
        )
            .toList();

        if (completed.isEmpty) {
          return const SizedBox.shrink();
        }

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: true,
          title: Text(
            'Completed (${completed.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            ...completed.map(
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
                        hidden: !item.isHidden,
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