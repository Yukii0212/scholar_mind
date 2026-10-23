import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/datasources/grading_component_firestore_datasource.dart';
import '../../data/repositories/grading_component_repository.dart';

final gradingComponentFirestoreDataSourceProvider =
Provider<GradingComponentFirestoreDataSource>(
      (ref) => GradingComponentFirestoreDataSource(),
);

final gradingComponentRepositoryProvider =
Provider<GradingComponentRepository>(
      (ref) => GradingComponentRepository(
    ref.watch(
      gradingComponentFirestoreDataSourceProvider,
    ),
  ),
);

final hasGradingStructureProvider =
StreamProvider.autoDispose.family<bool, String>(
      (
      ref,
      courseId,
      ) {
    final userId = ref.watch(activeUserProvider)?.uid;

    if (userId == null) {
      return Stream.value(false);
    }

    return ref
        .watch(
      gradingComponentRepositoryProvider,
    )
        .watchCourseComponents(courseId)
        .map(
          (components) =>
      components.isNotEmpty,
    );
  },
);
