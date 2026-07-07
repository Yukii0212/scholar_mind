import 'package:flutter/material.dart';

import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/sections/current_section.dart';
import '../../widgets/sections/hidden_section.dart';
import '../../widgets/sections/history_section.dart';
import '../../widgets/sections/future_section.dart';
import '../../widgets/dialogs/create_semester_dialog.dart';

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
            FutureSection(),
            HistorySection(),
            HiddenSection(),
          ],
        ),
      ),
    );
  }
}