import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/auth_provider.dart';
import 'course/course_provider.dart';
import 'grading/grading_provider.dart';
import 'semester/semester_provider.dart';

part 'grades_ownership_backfill_provider.g.dart';

const _prefsKeyPrefix = 'grades_ownership_backfilled_';

/// One-time, per-user backfill of the `ownerId` field on Course/
/// GradingComponent documents written before ownership tracking existed.
/// Rides on the current user's own normal sign-in permissions -- it can
/// only ever touch documents reachable through that user's own semesters.
/// Watch this once near the top of the Grades feature to trigger it.
@Riverpod(keepAlive: true)
class GradesOwnershipBackfill extends _$GradesOwnershipBackfill {
  @override
  void build() {
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    if (userId == null) {
      return;
    }

    unawaited(_run(userId));
  }

  Future<void> _run(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix$userId';

    if (prefs.getBool(key) ?? false) {
      return;
    }

    try {
      final semesters = await ref
          .read(semesterRepositoryProvider)
          .watchSemesters()
          .first;

      await ref.read(courseRepositoryProvider).backfillOwnership(
        userId: userId,
        semesterIds: [
          for (final semester in semesters) semester.id,
        ],
        componentRepository: ref.read(
          gradingComponentRepositoryProvider,
        ),
      );

      await prefs.setBool(key, true);
    } catch (_) {
      // Leave the flag unset so this retries next time Grades is opened.
    }
  }
}
