import 'package:flutter_riverpod/flutter_riverpod.dart';

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