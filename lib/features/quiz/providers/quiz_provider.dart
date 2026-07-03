import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_attempt.dart';
import '../domain/quiz_library_item.dart';
import '../domain/quiz_sort_order.dart';

final quizSortOrderProvider =
StateProvider<QuizSortOrder>(
      (_) => QuizSortOrder.lastOpened,
);

final quizLibraryProvider =
StateProvider<List<QuizLibraryItem>>(
      (_) => [],
);

final quizLibraryControllerProvider =
Provider<QuizLibraryController>(
      (ref) {
    return QuizLibraryController(ref);
  },
);

final activeQuizzesProvider =
Provider<List<QuizLibraryItem>>((ref) {

  final library = ref.watch(
    quizLibraryProvider,
  );

  return library.where((item) {

    return item.attempt.status ==
        QuizAttemptStatus.inProgress ||
        item.attempt.status ==
            QuizAttemptStatus.grading;

  }).toList();

});

final currentQuizProvider =
Provider<QuizLibraryItem?>((ref) {

  final active =
  ref.watch(activeQuizzesProvider);

  if (active.isEmpty) {
    return null;
  }

  return active.first;
});

class QuizLibraryController {
  QuizLibraryController(this.ref);

  final Ref ref;

  void updateAttempt(
      QuizAttempt updatedAttempt,
      ) {
    final library = [
      ...ref.read(
        quizLibraryProvider,
      ),
    ];

    final index =
    library.indexWhere(
          (item) =>
      item.attempt.id ==
          updatedAttempt.id,
    );

    if (index == -1) {
      return;
    }

    library[index] =
        library[index].copyWith(
          attempt: updatedAttempt,
          lastModifiedAt:
          DateTime.now(),
          lastOpenedAt:
          DateTime.now(),
        );

    ref
        .read(
      quizLibraryProvider
          .notifier,
    )
        .state = library;
  }
}