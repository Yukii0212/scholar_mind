import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grades_ownership_backfill_provider.dart';
import '../../providers/semester/current_semester_provider.dart';
import '../semester/semester_detail_screen.dart';
import '../semester/semester_overview_screen.dart';

class GradeHomeScreen extends ConsumerWidget {
  const GradeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(gradesOwnershipBackfillProvider);

    final semester = ref.watch(currentSemesterProvider);

    return semester.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(error.toString()),
        ),
      ),
      data: (semester) {
        if (semester == null) {
          return const SemesterOverviewScreen();
        }

        return SemesterDetailScreen(
          semester: semester,
        );
      },
    );
  }
}