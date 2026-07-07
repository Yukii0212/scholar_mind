import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/semester_provider.dart';
import '../semester/semester_actions.dart';
import '../semester/semester_card.dart';

class HiddenSection extends ConsumerWidget {
  const HiddenSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(semesterStreamProvider);

    return semesters.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        final hidden = list
            .where((semester) => semester.isHidden)
            .toList();

        if (hidden.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
          ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Hidden Semesters (${hidden.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            ...hidden.map(
                  (semester) => SemesterCard(
                semester: semester,
                onOpen: () => SemesterActions.open(
                  context,
                  semester,
                ),
                onEdit: () => SemesterActions.edit(
                  context,
                  semester,
                ),
                onDelete: () => SemesterActions.delete(
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

            const SizedBox(height: 24),
          ],
        ),
      ]
        );
      },
    );
  }
}