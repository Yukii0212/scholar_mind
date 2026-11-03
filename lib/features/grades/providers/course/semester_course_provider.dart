import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/course_model.dart';
import 'course_provider.dart';

final semesterCourseProvider =
StreamProvider.autoDispose.family<
    List<CourseModel>,
    String>(
      (ref, semesterId) {
    final userId = ref.watch(activeUserProvider)?.uid;

    if (userId == null) {
      return Stream.value(const []);
    }

    return ref
        .watch(courseRepositoryProvider)
        .watchSemesterCourses(
      userId: userId,
      semesterId: semesterId,
    );
  },
);
