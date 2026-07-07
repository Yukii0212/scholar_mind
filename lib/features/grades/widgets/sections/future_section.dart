import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/semester_provider.dart';
import '../semester/semester_actions.dart';
import '../semester/semester_card.dart';

class FutureSection extends ConsumerWidget {
  const FutureSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(semesterStreamProvider);

    return semesters.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        final now = DateTime.now();

        final future = list.where((semester) {
          if (semester.isHidden) {
            return false;
          }

          if (semester.isManuallyEdited) {
            return false;
          }

          return semester.startDate.isAfter(now);
        }).toList();

        if (future.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Future',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            ...future.map(
                  (semester) => SemesterCard(
                semester: semester,
                onOpen: () =>
                    SemesterActions.open(
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
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}