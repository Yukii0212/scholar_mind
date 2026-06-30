class QuestionTypeWeight {
  const QuestionTypeWeight({
    required this.multipleChoice,
    required this.trueFalse,
    required this.openEnded,
  });

  final int multipleChoice;

  final int trueFalse;

  final int openEnded;

  int get total =>
      multipleChoice +
          trueFalse +
          openEnded;
}