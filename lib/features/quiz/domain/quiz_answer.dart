class QuizAnswer {
  const QuizAnswer({
    this.selectedOptionIndex,
    this.openEndedAnswer = '',
    this.markedForReview = false,
    this.guessed = false,
    this.aiReviewPending = false,
    this.aiScore,
    this.aiMaxScore,
    this.aiFeedback,
  });

  final int? selectedOptionIndex;

  final String openEndedAnswer;

  final bool markedForReview;

  final bool guessed;

  final bool aiReviewPending;

  final int? aiScore;

  final int? aiMaxScore;

  final String? aiFeedback;

  QuizAnswer copyWith({
    int? selectedOptionIndex,
    String? openEndedAnswer,
    bool? markedForReview,
    bool? guessed,
    bool? aiReviewPending,
    int? aiScore,
    int? aiMaxScore,
    String? aiFeedback,
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

      aiReviewPending:
      aiReviewPending ??
          this.aiReviewPending,

      aiScore:
      aiScore ??
          this.aiScore,

      aiMaxScore:
      aiMaxScore ??
          this.aiMaxScore,

      aiFeedback:
      aiFeedback ??
          this.aiFeedback,
    );
  }
}