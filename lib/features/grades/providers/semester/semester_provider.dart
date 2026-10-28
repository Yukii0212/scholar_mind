import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/semester_model.dart';
import '../../data/repositories/semester_repository.dart';

final semesterRepositoryProvider = Provider<SemesterRepository>(
  (ref) => SemesterRepository(),
);

final semesterStreamProvider = StreamProvider<List<SemesterModel>>(
  (ref) {
    final userId = ref.watch(activeUserProvider)?.uid;

    if (userId == null) {
      return Stream.value(const []);
    }

    return ref.watch(semesterRepositoryProvider).watchSemesters(userId);
  },
);

final semesterProvider =
    Provider.autoDispose.family<AsyncValue<SemesterModel>, String>(
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
