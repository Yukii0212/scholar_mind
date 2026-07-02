enum QuizDifficulty {
  easy,
  medium,
  hard,
  mixed;

  @override
  String toString() {
    switch (this) {
      case QuizDifficulty.easy:
        return 'Easy';

      case QuizDifficulty.medium:
        return 'Medium';

      case QuizDifficulty.hard:
        return 'Hard';

      case QuizDifficulty.mixed:
        return 'Mixed';
    }
  }

  String toPrompt() {
    switch (this) {
      case QuizDifficulty.easy:
        return 'Easy';

      case QuizDifficulty.medium:
        return 'Medium';

      case QuizDifficulty.hard:
        return 'Hard';

      case QuizDifficulty.mixed:
        return 'Mixed';
    }
  }
}