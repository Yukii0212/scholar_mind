import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
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
    final userId = ref.watch(authStateProvider).valueOrNull?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    return ref
        .watch(courseRepositoryProvider)
        .watchCourses(userId);
  },
);

final courseProvider =
StreamProvider.family<
    CourseModel,
    String>(
      (ref, courseId) {
    return ref
        .watch(
      courseRepositoryProvider,
    )
        .watchCourse(
      courseId,
    );
  },
);
