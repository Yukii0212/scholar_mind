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

final currentQuizProvider =
Provider<QuizLibraryItem?>((ref) {

  final library =
  ref.watch(
    quizLibraryProvider,
  );

  try {
    return library.firstWhere(
          (item) =>
      item.attempt.status ==
          QuizAttemptStatus.inProgress,
    );
  } catch (_) {
    return null;
  }
});