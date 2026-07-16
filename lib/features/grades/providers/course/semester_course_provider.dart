import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import 'course_provider.dart';

final semesterCourseProvider =
StreamProvider.family<
    List<CourseModel>,
    String>(
      (ref, semesterId) {
    return ref
        .watch(courseRepositoryProvider)
        .watchSemesterCourses(
      semesterId,
    );
  },
);