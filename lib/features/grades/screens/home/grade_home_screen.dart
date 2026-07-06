import 'package:flutter/material.dart';

import '../../widgets/common/grade_speed_dial.dart';
import '../../widgets/home/grade_empty_state.dart';

class GradeHomeScreen extends StatelessWidget {
  const GradeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const GradeEmptyState(),
      floatingActionButton: GradeSpeedDial(
        onCreateSemester: () {
          // We'll hook this up to CreateSemesterDialog next.
        },
      ),
    );
  }
}