import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/datasources/grading_component_firestore_datasource.dart';
import '../../data/models/grading_component_model.dart';
import '../../data/repositories/grading_component_repository.dart';

final gradingComponentFirestoreDataSourceProvider =
    Provider<GradingComponentFirestoreDataSource>(
  (ref) => GradingComponentFirestoreDataSource(),
);

final gradingComponentRepositoryProvider = Provider<GradingComponentRepository>(
  (ref) => GradingComponentRepository(
    ref.watch(
      gradingComponentFirestoreDataSourceProvider,
    ),
  ),
);

final gradingComponentsProvider = StreamProvider.autoDispose
    .family<List<GradingComponentModel>, String>(
  (
    ref,
    courseId,
  ) {
    final userId = ref.watch(activeUserProvider)?.uid;

    if (userId == null) {
      return Stream.value(const <GradingComponentModel>[]);
    }

    return ref
        .watch(
          gradingComponentRepositoryProvider,
        )
        .watchCourseComponents(userId, courseId);
  },
);

final hasGradingStructureProvider =
    Provider.autoDispose.family<AsyncValue<bool>, String>(
  (ref, courseId) => ref
      .watch(gradingComponentsProvider(courseId))
      .whenData((components) => components.isNotEmpty),
);
