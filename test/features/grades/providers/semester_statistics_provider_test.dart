import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/features/grades/data/models/assessment_entry_model.dart';
import 'package:scholar_mind/features/grades/data/models/course_model.dart';
import 'package:scholar_mind/features/grades/data/models/grading_component_model.dart';
import 'package:scholar_mind/features/grades/providers/assessment/assessment_provider.dart';
import 'package:scholar_mind/features/grades/providers/course/semester_course_provider.dart';
import 'package:scholar_mind/features/grades/providers/grading/grading_provider.dart';
import 'package:scholar_mind/features/grades/providers/semester/semester_statistics_provider.dart';

void main() {
  test('semester statistics react to grading structure changes', () async {
    final courses = StreamController<List<CourseModel>>();
    final components = StreamController<List<GradingComponentModel>>();
    final assessments = StreamController<List<AssessmentEntryModel>>();
    addTearDown(courses.close);
    addTearDown(components.close);
    addTearDown(assessments.close);

    final container = ProviderContainer(
      overrides: [
        semesterCourseProvider.overrideWith(
          (ref, semesterId) => courses.stream,
        ),
        gradingComponentsProvider.overrideWith(
          (ref, courseId) => components.stream,
        ),
        assessmentEntriesProvider.overrideWith(
          (ref, courseId) => assessments.stream,
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      semesterStatisticsProvider('semester-1'),
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final now = DateTime(2026, 1, 1);
    final course = CourseModel(
      id: 'course-1',
      ownerId: 'user-1',
      semesterId: 'semester-1',
      name: 'Course',
      createdAt: now,
      updatedAt: now,
    );

    courses.add([course]);
    components.add(const []);
    assessments.add(const []);
    await pumpEventQueue();

    var statistics = container.read(
      semesterStatisticsProvider('semester-1'),
    );
    expect(statistics.requireValue.single.summary.totalWeight, 0);

    components.add([
      GradingComponentModel(
        id: 'component-1',
        ownerId: 'user-1',
        courseId: course.id,
        parentId: null,
        name: 'Final',
        weight: 100,
        order: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    await pumpEventQueue();

    statistics = container.read(
      semesterStatisticsProvider('semester-1'),
    );
    expect(statistics.requireValue.single.summary.totalWeight, 100);
  });
}
