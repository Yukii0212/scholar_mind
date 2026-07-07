import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/current_semester_provider.dart';
import '../../screens/semester/semester_detail_screen.dart';
import '../semester/rename_semester_dialog.dart';
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
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SemesterDetailScreen(
                      semester: semester,
                    ),
                  ),
                );
              },
              onRename: () {
                showDialog(
                  context: context,
                  builder: (_) => RenameSemesterDialog(
                    semester: semester,
                  ),
                );
              },
              onEdit: () {},
              onDelete: () {},
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}