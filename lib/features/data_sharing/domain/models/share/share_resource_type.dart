enum ShareResourceType {
  note('note'),
  noteFolder('note_folder'),
  // Dart identifier renamed (Deck -> Set) alongside the rest of the
  // Flashcards module; the underlying value stays 'flashcard_deck' so
  // already-generated archives and stored share records keep resolving.
  flashcardSet('flashcard_deck'),
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

extension ShareResourceTypeLabel on ShareResourceType {
  String pluralLabel(int count) {
    final singular = switch (this) {
      ShareResourceType.note => 'note',
      ShareResourceType.noteFolder => 'folder',
      ShareResourceType.flashcardSet => 'flashcard set',
      ShareResourceType.flashcard => 'flashcard',
      ShareResourceType.quiz => 'quiz',
      ShareResourceType.quizFolder => 'quiz folder',
      ShareResourceType.countdown => 'countdown',
      ShareResourceType.gradeSemester => 'semester',
      ShareResourceType.gradeCourse => 'course',
      ShareResourceType.gradingComponent => 'grading component',
      ShareResourceType.assessmentEntry => 'assessment',
    };

    if (count == 1) return singular;

    return this == ShareResourceType.quiz ? 'quizzes' : '${singular}s';
  }
}