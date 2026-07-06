import 'package:flutter/material.dart';

import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/history/history_section.dart';
import '../../widgets/semester/current_semester_section.dart';
import '../../widgets/semester/create_semester_dialog.dart';

class GradeHomeScreen extends StatelessWidget {
  const GradeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          CurrentSemesterSection(),
          SizedBox(height: 32),
          HistorySection(),
          SizedBox(height: 100),
        ],
      ),
      floatingActionButton: GradeSpeedDial(
        onCreateSemester: () {
          showDialog(
            context: context,
            builder: (_) => const CreateSemesterDialog(),
          );
        },
      ),
    );
  }
}