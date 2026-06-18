enum NoteCategory {
  lectureNotes('lectureNotes', 'Lecture notes'),
  selfStudyNotes('selfStudyNotes', 'Self-study notes'),
  pastYearQuestions('pastYearQuestions', 'Past-year questions');

  const NoteCategory(this.key, this.label);

  final String key;
  final String label;

  static NoteCategory fromKey(String key) {
    return values.firstWhere(
      (category) => category.key == key,
      orElse: () => NoteCategory.lectureNotes,
    );
  }
}
