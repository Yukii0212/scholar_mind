import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/semester_provider.dart';
import '../../screens/semester/semester_detail_screen.dart';
import '../semester/rename_semester_dialog.dart';
import '../semester/semester_card.dart';

class HistorySection extends ConsumerWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(semesterStreamProvider);

    return semesters.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();

        final history = list.where((semester) {
          if (semester.isManuallyEdited) {
            return !semester.isCurrent;
          }

          return now.isAfter(semester.endDate);
        }).toList();

        if (history.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...history.map(
                  (semester) => SemesterCard(
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
            ),
          ],
        );
      },
    );
  }
}