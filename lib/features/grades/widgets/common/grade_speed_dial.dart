import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GradeSpeedDial extends StatelessWidget {
  const GradeSpeedDial({
    super.key,
    this.onCreateSemester,
    this.onCreateCourse,
    this.onImportCourse,
    this.onCreateGradingStructure,
    this.onImportGradingTemplate,
  });

  final VoidCallback? onCreateSemester;
  final VoidCallback? onCreateCourse;
  final VoidCallback? onImportCourse;
  final VoidCallback? onCreateGradingStructure;
  final VoidCallback? onImportGradingTemplate;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 12,
      children: [
        if (onImportGradingTemplate != null)
          SpeedDialChild(
            child: const Icon(
              Icons.bookmarks_outlined,
            ),
            label: 'Use Template',
            onTap: onImportGradingTemplate,
          ),

        if (onCreateGradingStructure != null)
          SpeedDialChild(
            child: const Icon(
              Icons.account_tree_outlined,
            ),
            label: 'Create Grading Structure',
            onTap: onCreateGradingStructure,
          ),

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