import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/google_classroom_service.dart';

part 'google_classroom_provider.g.dart';

@riverpod
GoogleClassroomService
googleClassroomService(
    GoogleClassroomServiceRef ref,
    ) {
  return GoogleClassroomService();
}

@riverpod
Future<List<ClassroomCourse>>
classroomCourses(
    ClassroomCoursesRef ref,
    ) {
  return ref
      .watch(
    googleClassroomServiceProvider,
  )
      .fetchCourses();
}