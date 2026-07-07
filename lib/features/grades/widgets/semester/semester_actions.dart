import 'package:flutter/material.dart';

import '../../data/models/semester_model.dart';
import '../../screens/semester/semester_detail_screen.dart';
import 'rename_semester_dialog.dart';

class SemesterActions {
  const SemesterActions._();

  static void open(
      BuildContext context,
      SemesterModel semester,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SemesterDetailScreen(
          semester: semester,
        ),
      ),
    );
  }

  static void rename(
      BuildContext context,
      SemesterModel semester,
      ) {
    showDialog(
      context: context,
      builder: (_) => RenameSemesterDialog(
        semester: semester,
      ),
    );
  }

  static void edit(
      BuildContext context,
      SemesterModel semester,
      ) {}

  static void delete(
      BuildContext context,
      SemesterModel semester,
      ) {}
}