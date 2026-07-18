import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../services/calculation/course_calculation_service.dart';
import '../../services/calculation/course_calculation_summary.dart';
import '../assessment/assessment_provider.dart';
import '../course/semester_course_provider.dart';
import '../grading/grading_provider.dart';

class SemesterCoursePriority {
  const SemesterCoursePriority({
    required this.course,
    required this.summary,
  });

  final CourseModel course;
  final CourseCalculationSummary summary;
}

final semesterStatisticsProvider =
FutureProvider.family<List<SemesterCoursePriority>, String>(
      (ref, semesterId) async {
    final repository = ref.read(
      gradingComponentRepositoryProvider,
    );

    final courses = await ref.watch(
      semesterCourseProvider(
        semesterId,
      ).future,
    );

    final priorities =
    <SemesterCoursePriority>[];

    for (final course in courses) {
      final gradingComponents =
      await repository
          .getCourseComponents(
        course.id,
      );

      final assessments =
      await ref.watch(
        assessmentEntriesProvider(
          course.id,
        ).future,
      );

      final summary =
      CourseCalculationService
          .calculate(
        components:
        gradingComponents,
        assessments:
        assessments,
      );

      priorities.add(
        SemesterCoursePriority(
          course: course,
          summary: summary,
        ),
      );
    }

    priorities.sort(
          (a, b) {
        final aTarget =
            a.course.targetScore;
        final bTarget =
            b.course.targetScore;

        // No targets -> alphabetical.
        if (aTarget == null &&
            bTarget == null) {
          return a.course.name
              .compareTo(
            b.course.name,
          );
        }

        // Courses with targets come first.
        if (aTarget == null) {
          return 1;
        }

        if (bTarget == null) {
          return -1;
        }

        final aAchievable =
        a.summary.isAchievable(
          aTarget,
        );

        final bAchievable =
        b.summary.isAchievable(
          bTarget,
        );

        // Impossible targets first.
        if (aAchievable !=
            bAchievable) {
          return aAchievable
              ? 1
              : -1;
        }

        final aRequired =
            a.summary
                .requiredPercentageFor(
              aTarget,
            ) ??
                0.0;

        final bRequired =
            b.summary
                .requiredPercentageFor(
              bTarget,
            ) ??
                0.0;

        // Higher required percentage first.
        return bRequired.compareTo(
          aRequired,
        );
      },
    );

    return priorities;
  },
);