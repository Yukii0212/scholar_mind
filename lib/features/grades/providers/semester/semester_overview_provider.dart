import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/semester_model.dart';
import 'current_semester_provider.dart';
import 'semester_provider.dart';

final shouldShowSemesterOverviewProvider =
Provider<bool>((ref) {
  final currentSemester =
  ref.watch(currentSemesterProvider);

  final semesters =
  ref.watch(semesterStreamProvider);

  return currentSemester.when(
    data: (semester) {
      if (semester != null) {
        return false;
      }

      return semesters.maybeWhen(
        data: (list) => list.isNotEmpty,
        orElse: () => false,
      );
    },
    loading: () => false,
    error: (_, __) => false,
  );
});