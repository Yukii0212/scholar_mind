import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/semester_model.dart';
import '../../data/repositories/semester_repository.dart';

final semesterRepositoryProvider = Provider<SemesterRepository>(
      (ref) => SemesterRepository(),
);

final semesterStreamProvider =
StreamProvider<List<SemesterModel>>(
      (ref) {
    return ref
        .watch(semesterRepositoryProvider)
        .watchSemesters();
  },
);

final semesterProvider = Provider.family<
    AsyncValue<SemesterModel>,
    String>(
      (ref, semesterId) {
    final semesters = ref.watch(
      semesterStreamProvider,
    );

    return semesters.whenData(
          (list) => list.firstWhere(
            (semester) => semester.id == semesterId,
      ),
    );
  },
);