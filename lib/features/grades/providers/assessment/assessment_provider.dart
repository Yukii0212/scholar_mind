import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/datasources/assessment_firestore_datasource.dart';
import '../../data/repositories/assessment_repository.dart';

final assessmentFirestoreDataSourceProvider =
Provider(
      (ref) =>
      AssessmentFirestoreDataSource(
        FirebaseFirestore.instance,
      ),
);

final assessmentRepositoryProvider =
Provider(
      (ref) => AssessmentRepository(
    ref.watch(
      assessmentFirestoreDataSourceProvider,
    ),
  ),
);

final assessmentEntriesProvider =
StreamProvider.autoDispose.family(
      (
      ref,
      String courseId,
      ) {
    final userId = ref.watch(activeUserProvider)?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    return ref
        .watch(
      assessmentRepositoryProvider,
    )
        .watchEntries(
      courseId,
    );
  },
);
