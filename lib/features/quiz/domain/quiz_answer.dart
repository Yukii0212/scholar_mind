class QuizAnswer {
  const QuizAnswer({
    this.selectedOptionIndex,
    this.openEndedAnswer = '',
    this.markedForReview = false,
    this.guessed = false,
  });

  final int? selectedOptionIndex;

  final String openEndedAnswer;

  final bool markedForReview;

  final bool guessed;

  QuizAnswer copyWith({
    int? selectedOptionIndex,
    String? openEndedAnswer,
    bool? markedForReview,
    bool? guessed,
  }) {
    return QuizAnswer(
      selectedOptionIndex:
      selectedOptionIndex ??
          this.selectedOptionIndex,
      openEndedAnswer:
      openEndedAnswer ??
          this.openEndedAnswer,
      markedForReview:
      markedForReview ??
          this.markedForReview,
      guessed:
      guessed ??
          this.guessed,
    );
  }
}