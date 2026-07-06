import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/semester/current_semester_provider.dart';
import '../semester/semester_detail_screen.dart';
import '../semester/semester_overview_screen.dart';

import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/semester/create_semester_dialog.dart';

class GradeHomeScreen extends ConsumerWidget {
  const GradeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semester = ref.watch(currentSemesterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Tracker'),
      ),
      floatingActionButton: GradeSpeedDial(
        onCreateSemester: () {
          showDialog(
            context: context,
            builder: (_) => const CreateSemesterDialog(),
          );
        },
      ),
      body: semester.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
        data: (semester) {
          if (semester == null) {
            return const SemesterOverviewScreen();
          }

          return const SemesterDetailScreen();
        },
      ),
    );
  }
}