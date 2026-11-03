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

final semesterStatisticsProvider = Provider.autoDispose
    .family<AsyncValue<List<SemesterCoursePriority>>, String>(
  (ref, semesterId) {
    final courses = ref.watch(semesterCourseProvider(semesterId));

    return courses.when(
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      data: (courses) {
        Object? dependencyError;
        StackTrace? dependencyStackTrace;
        var isLoading = false;
        final priorities = <SemesterCoursePriority>[];

        for (final course in courses) {
          final components = ref.watch(gradingComponentsProvider(course.id));
          final assessments = ref.watch(assessmentEntriesProvider(course.id));

          if (dependencyError == null && components.hasError) {
            dependencyError = components.error;
            dependencyStackTrace = components.stackTrace;
          }

          if (dependencyError == null && assessments.hasError) {
            dependencyError = assessments.error;
            dependencyStackTrace = assessments.stackTrace;
          }

          if (components.isLoading || assessments.isLoading) {
            isLoading = true;
          }

          final componentData = components.valueOrNull;
          final assessmentData = assessments.valueOrNull;

          if (componentData == null || assessmentData == null) {
            continue;
          }

          priorities.add(
            SemesterCoursePriority(
              course: course,
              summary: CourseCalculationService.calculate(
                components: componentData,
                assessments: assessmentData,
              ),
            ),
          );
        }

        if (dependencyError != null) {
          return AsyncValue.error(
            dependencyError,
            dependencyStackTrace ?? StackTrace.current,
          );
        }

        if (isLoading) {
          return const AsyncValue.loading();
        }

        priorities.sort(_comparePriorities);
        return AsyncValue.data(priorities);
      },
    );
  },
);

int _comparePriorities(
  SemesterCoursePriority a,
  SemesterCoursePriority b,
) {
  final aTarget = a.course.targetScore;
  final bTarget = b.course.targetScore;

  if (aTarget == null && bTarget == null) {
    return a.course.name.compareTo(b.course.name);
  }

  if (aTarget == null) {
    return 1;
  }

  if (bTarget == null) {
    return -1;
  }

  final aAchievable = a.summary.isAchievable(aTarget);
  final bAchievable = b.summary.isAchievable(bTarget);

  if (aAchievable != bAchievable) {
    return aAchievable ? 1 : -1;
  }

  final aRequired = a.summary.requiredPercentageFor(aTarget) ?? 0;
  final bRequired = b.summary.requiredPercentageFor(bTarget) ?? 0;

  return bRequired.compareTo(aRequired);
}
