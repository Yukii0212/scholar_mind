class QuestionTypeWeight {
  const QuestionTypeWeight({
    required this.multipleChoice,
    required this.trueFalse,
    required this.openEnded,
    this.isCustom = false,
  });

  final int multipleChoice;
  final int trueFalse;
  final int openEnded;

  final bool isCustom;

  QuestionTypeWeight copyWith({
    int? multipleChoice,
    int? trueFalse,
    int? openEnded,
    bool? isCustom,
  }) {
    return QuestionTypeWeight(
      multipleChoice:
      multipleChoice ??
          this.multipleChoice,
      trueFalse:
      trueFalse ??
          this.trueFalse,
      openEnded:
      openEnded ??
          this.openEnded,
      isCustom:
      isCustom ??
          this.isCustom,
    );
  }
}