import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/course_firestore_datasource.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

final courseFirestoreDataSourceProvider =
Provider<CourseFirestoreDataSource>(
      (ref) => CourseFirestoreDataSource(),
);

final courseRepositoryProvider =
Provider<CourseRepository>(
      (ref) => CourseRepository(
    ref.watch(courseFirestoreDataSourceProvider),
  ),
);

final courseStreamProvider =
StreamProvider<List<CourseModel>>(
      (ref) {
    return ref
        .watch(courseRepositoryProvider)
        .watchCourses();
  },
);

final personalCourseProvider =
StreamProvider<List<CourseModel>>(
      (ref) {
    return ref
        .watch(courseRepositoryProvider)
        .watchPersonalCourses();
  },
);