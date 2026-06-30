import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quiz_repository.dart';

final quizRepositoryProvider =
Provider<QuizRepository>(
      (ref) {
    return const QuizRepository();
  },
);