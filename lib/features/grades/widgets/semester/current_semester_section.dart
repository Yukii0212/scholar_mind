import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/current_semester_provider.dart';
import '../home/grade_empty_state.dart';

class CurrentSemesterSection extends ConsumerWidget {
  const CurrentSemesterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semester = ref.watch(currentSemesterProvider);

    return semester.when(
      data: (semester) {
        if (semester == null) {
          return const GradeEmptyState();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  semester.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('MMM yyyy').format(semester.startDate)} - '
                      '${DateFormat('MMM yyyy').format(semester.endDate)}',
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
    );
  }
}