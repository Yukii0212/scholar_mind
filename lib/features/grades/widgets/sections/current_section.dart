import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/current_semester_provider.dart';
import '../semester/semester_actions.dart';
import '../semester/semester_card.dart';

class CurrentSection extends ConsumerWidget {
  const CurrentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSemester = ref.watch(currentSemesterProvider);

    return currentSemester.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (semester) {
        if (semester == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            SemesterCard(
              semester: semester,
              onOpen: () =>
                  SemesterActions.open(
                    context,
                    semester,
                  ),
              onRename: () =>
                  SemesterActions.rename(
                    context,
                    semester,
                  ),
              onEdit: () =>
                  SemesterActions.edit(
                    context,
                    semester,
                  ),
              onDelete: () =>
                  SemesterActions.delete(
                    context,
                    semester,
                  ),
              onToggleHidden: () =>
                  SemesterActions.toggleHidden(
                    context,
                    semester,
                  ),
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}