import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/grades/widgets/semester/semester_card.dart';

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

        return SemesterCard(
          semester: semester,
          onOpen: () {},
          onRename: () {},
          onEdit: () {},
          onDelete: () {},
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