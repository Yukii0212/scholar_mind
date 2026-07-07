import 'package:flutter/material.dart';

import '../../data/models/semester_model.dart';
import '../../screens/semester/semester_detail_screen.dart';
import '../dialogs/delete_semester_dialog.dart';
import '../dialogs/edit_semester_dialog.dart';
import '../dialogs/rename_semester_dialog.dart';

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
      ) {
    showDialog(
      context: context,
      builder: (_) => EditSemesterDialog(
        semester: semester,
      ),
    );
  }

  static void toggleHidden(
      BuildContext context,
      SemesterModel semester,
      ) {}

  static Future<void> delete(
      BuildContext context,
      SemesterModel semester,
      ) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteSemesterDialog(
        semester: semester,
      ),
    ) ??
        false;

    if (!deleted || !context.mounted) {
      return;
    }

    Navigator.of(context).maybePop();
  }
}