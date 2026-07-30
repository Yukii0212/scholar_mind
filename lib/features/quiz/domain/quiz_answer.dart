class QuizAnswer {
  const QuizAnswer({
    this.selectedOptionIndex,
    this.openEndedAnswer = '',
    this.markedForReview = false,
    this.guessed = false,
    this.notImportant = false,
    this.notImportantFeedbackId,
    this.aiReviewPending = false,
    this.aiScore,
    this.aiMaxScore,
    this.aiFeedback,
  });

  final int? selectedOptionIndex;

  final String openEndedAnswer;

  final bool markedForReview;

  final bool guessed;

  /// Excluded from scoring on the results screen -- see
  /// QuizFeedbackRepository for the separate, persisted "Not Important"
  /// feedback this is paired with when the user flags a question.
  final bool notImportant;

  /// The id of the QuizFeedbackEntry document created when this question
  /// was flagged, so un-flagging it (before submitting, or from the
  /// results screen) can delete that entry too -- without this, un-
  /// flagging only cleared the local exclusion-from-grading and left the
  /// persisted feedback entry behind forever.
  final String? notImportantFeedbackId;

  final bool aiReviewPending;

  final int? aiScore;

  final int? aiMaxScore;

  final String? aiFeedback;

  QuizAnswer copyWith({
    int? selectedOptionIndex,
    String? openEndedAnswer,
    bool? markedForReview,
    bool? guessed,
    bool? notImportant,
    String? notImportantFeedbackId,
    bool clearNotImportantFeedbackId = false,
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

      notImportant:
      notImportant ??
          this.notImportant,

      notImportantFeedbackId: clearNotImportantFeedbackId
          ? null
          : notImportantFeedbackId ?? this.notImportantFeedbackId,

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
  Map<String, dynamic> toJson() {
    return {
      'selectedOptionIndex':
      selectedOptionIndex,
      'openEndedAnswer':
      openEndedAnswer,
      'markedForReview':
      markedForReview,
      'guessed':
      guessed,
      'notImportant':
      notImportant,
      'notImportantFeedbackId':
      notImportantFeedbackId,
      'aiReviewPending':
      aiReviewPending,
      'aiScore':
      aiScore,
      'aiMaxScore':
      aiMaxScore,
      'aiFeedback':
      aiFeedback,
    };
  }

  factory QuizAnswer.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuizAnswer(
      selectedOptionIndex:
      json['selectedOptionIndex']
      as int?,

      openEndedAnswer:
      json['openEndedAnswer']
      as String? ??
          '',

      markedForReview:
      json['markedForReview']
      as bool? ??
          false,

      guessed:
      json['guessed']
      as bool? ??
          false,

      notImportant:
      json['notImportant']
      as bool? ??
          false,

      notImportantFeedbackId:
      json['notImportantFeedbackId']
      as String?,

      aiReviewPending:
      json['aiReviewPending']
      as bool? ??
          false,

      aiScore:
      json['aiScore']
      as int?,

      aiMaxScore:
      json['aiMaxScore']
      as int?,

      aiFeedback:
      json['aiFeedback']
      as String?,
    );
  }
}
