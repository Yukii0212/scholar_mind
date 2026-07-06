import 'package:flutter/material.dart';

import '../home/grade_empty_state.dart';

class CurrentSemesterSection extends StatelessWidget {
  const CurrentSemesterSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Later this will come from currentSemesterProvider.
    const hasCurrentSemester = false;

    if (!hasCurrentSemester) {
      return const GradeEmptyState();
    }

    return const SizedBox.shrink();
  }
}