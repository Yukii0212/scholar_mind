import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
StreamProvider.family(
      (
      ref,
      String courseId,
      ) {
    return ref
        .watch(
      assessmentRepositoryProvider,
    )
        .watchEntries(
      courseId,
    );
  },
);