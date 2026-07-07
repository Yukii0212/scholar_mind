import 'package:flutter/material.dart';

import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/current/current_section.dart';
import '../../widgets/history/history_section.dart';
import '../../widgets/semester/create_semester_dialog.dart';

class SemesterOverviewScreen extends StatelessWidget {
  const SemesterOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semesters'),
      ),
      floatingActionButton: GradeSpeedDial(
        onCreateSemester: () {
          showDialog(
            context: context,
            builder: (_) => const CreateSemesterDialog(),
          );
        },
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentSection(),
            HistorySection(),
          ],
        ),
      ),
    );
  }
}