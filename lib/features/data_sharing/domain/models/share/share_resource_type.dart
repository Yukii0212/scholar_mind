enum ShareResourceType {
  note('note'),
  noteFolder('note_folder'),
  flashcardDeck('flashcard_deck'),
  flashcard('flashcard'),
  quiz('quiz'),
  quizFolder('quiz_folder'),
  countdown('countdown'),
  gradeSemester('grade_semester'),
  gradeCourse('grade_course'),
  gradingComponent('grading_component'),
  assessmentEntry('assessment_entry');

  const ShareResourceType(this.value);

  final String value;

  static ShareResourceType? fromValue(
      String value,
      ) {
    for (final type in values) {
      if (type.value == value) {
        return type;
      }
    }

    return null;
  }
}