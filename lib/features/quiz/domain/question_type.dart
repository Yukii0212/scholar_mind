enum QuestionType {
  multipleChoice,
  trueFalse,
  openEnded;

  factory QuestionType.fromJson(
      String value,
      ) {
    switch (value.toLowerCase()) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;

      case 'true_false':
        return QuestionType.trueFalse;

      case 'open_ended':
        return QuestionType.openEnded;

      default:
        throw Exception(
          'Unknown question type: $value',
        );
    }
  }

  String toJson() {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'multiple_choice';

      case QuestionType.trueFalse:
        return 'true_false';

      case QuestionType.openEnded:
        return 'open_ended';
    }
  }
}