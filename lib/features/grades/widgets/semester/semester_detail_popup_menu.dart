import 'package:flutter/material.dart';

import '../../data/models/semester_model.dart';
import 'semester_actions.dart';

class SemesterDetailPopupMenu extends StatelessWidget {
  const SemesterDetailPopupMenu({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {

          case 'edit':
            SemesterActions.edit(
              context,
              semester,
            );
            break;

          case 'delete':
            SemesterActions.delete(
              context,
              semester,
            );
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit Semester'),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete Semester'),
        ),
      ],
    );
  }
}