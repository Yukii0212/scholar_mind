import 'package:flutter/material.dart';

import '../../../../core/theme/app_design.dart';
import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/sections/semester/current_section.dart';
import '../../widgets/sections/semester/hidden_section.dart';
import '../../widgets/sections/semester/history_section.dart';
import '../../widgets/sections/semester/future_section.dart';
import '../../widgets/dialogs/semester/create_semester_dialog.dart';

class SemesterOverviewScreen extends StatelessWidget {
  const SemesterOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: GradeSpeedDial(
        onCreateSemester: () {
          showDialog(
            context: context,
            builder: (_) => const CreateSemesterDialog(),
          );
        },
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScholarSectionHeader(
              title: 'Semesters',
              subtitle: 'Track current, upcoming, and completed terms',
            ),
            SizedBox(height: 20),
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
