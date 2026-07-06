import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/semester_model.dart';
import 'semester_provider.dart';

final currentSemesterProvider =
Provider<AsyncValue<SemesterModel?>>(
      (ref) {
    final semesters =
    ref.watch(semesterStreamProvider);

    return semesters.whenData((list) {
      final now = DateTime.now();

      SemesterModel? currentSemester;

      for (final semester in list) {
        if (semester.isManuallyEdited) {
          if (semester.isCurrent) {
            currentSemester = semester;
            break;
          }

          continue;
        }

        final isCurrent =
            !now.isBefore(semester.startDate) &&
                !now.isAfter(semester.endDate);

        if (isCurrent) {
          currentSemester = semester;
          break;
        }
      }

      return currentSemester;
    });
  },
);