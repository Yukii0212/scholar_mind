import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GradeSpeedDial extends StatelessWidget {
  const GradeSpeedDial({
    super.key,
    required this.onCreateSemester,
  });

  final VoidCallback onCreateSemester;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.calendar_month),
          label: 'Create Semester',
          onTap: onCreateSemester,
        ),
      ],
    );
  }
}