import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/course_model.dart';
import 'course_provider.dart';

final semesterCourseProvider =
StreamProvider.family<
    List<CourseModel>,
    String>(
      (ref, semesterId) {
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    return ref
        .watch(courseRepositoryProvider)
        .watchSemesterCourses(
      userId: userId,
      semesterId: semesterId,
    );
  },
);
