import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/semester_model.dart';
import '../../providers/semester/semester_provider.dart';
import '../../screens/semester/semester_detail_screen.dart';
import '../dialogs/semester/delete_semester_dialog.dart';
import '../dialogs/semester/edit_semester_dialog.dart';

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

  static Future<void> toggleHidden(
    BuildContext context,
    SemesterModel semester,
  ) async {
    final container = ProviderScope.containerOf(context);
    final userId = container.read(activeUserProvider)?.uid;

    if (userId == null) {
      return;
    }

    await container.read(semesterRepositoryProvider).toggleHidden(
          userId: userId,
          semesterId: semester.id,
          isHidden: !semester.isHidden,
        );
  }

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
