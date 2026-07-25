enum ShareResourceType {
  note('note'),
  noteFolder('note_folder'),
  flashcardDeck('flashcard_deck'),
  flashcard('flashcard'),
  quiz('quiz'),
  countdown('countdown'),
  gradeSemester('grade_semester');

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