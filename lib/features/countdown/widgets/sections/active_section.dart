import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../providers/countdown_provider.dart';
import '../countdown_actions.dart';
import '../countdown_card.dart';
import '../countdown_navigation.dart';

class ActiveSection extends ConsumerWidget {
  const ActiveSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref
        .watch(upcomingCountdownsProvider)
        .where((item) => !item.isHidden)
        .toList();
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    if (upcoming.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const Gap(16),

        ...upcoming.map(
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

        const Gap(24),
      ],
    );
  }
}