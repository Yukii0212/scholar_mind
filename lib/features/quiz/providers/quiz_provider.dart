import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_attempt.dart';
import '../domain/quiz_library_item.dart';
import '../domain/quiz_sort_order.dart';
import 'quiz_library_provider.dart';
import '../domain/quiz_folder.dart';

final quizSortOrderProvider =
StateProvider<QuizSortOrder>(
      (_) => QuizSortOrder.lastOpened,
);

final activeQuizzesProvider =
Provider<List<QuizAttempt>>((ref) {

  final quizzes = ref.watch(
    quizzesInFolderProvider(
      QuizFolder.rootId,
    ),
  );

  return quizzes.maybeWhen(
    data: (items) {

      return items.where(
            (quiz) =>
        quiz.status ==
            QuizAttemptStatus.inProgress ||
            quiz.status ==
                QuizAttemptStatus.grading,
      ).toList();

    },

    orElse: () => [],
  );

});
final currentQuizProvider =
Provider<QuizAttempt?>((ref) {

  final active =
  ref.watch(activeQuizzesProvider);

  if (active.isEmpty) {
    return null;
  }

  return active.first;
});