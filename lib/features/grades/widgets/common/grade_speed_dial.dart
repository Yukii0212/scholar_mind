import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GradeSpeedDial extends StatelessWidget {
  const GradeSpeedDial({
    super.key,
    this.onCreateSemester,
    this.onCreateCourse,
    this.onImportCourse,
  });

  final VoidCallback? onCreateSemester;
  final VoidCallback? onCreateCourse;
  final VoidCallback? onImportCourse;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 12,
      children: [
        if (onCreateSemester != null)
          SpeedDialChild(
            child: const Icon(Icons.calendar_month),
            label: 'Create Semester',
            onTap: onCreateSemester,
          ),

        if (onImportCourse != null)
          SpeedDialChild(
            child: const Icon(Icons.file_copy_outlined),
            label: 'Import Course',
            onTap: onImportCourse,
          ),

        if (onCreateCourse != null)
          SpeedDialChild(
            child: const Icon(Icons.menu_book_outlined),
            label: 'Create Course',
            onTap: onCreateCourse,
          ),


      ],
    );
  }
}