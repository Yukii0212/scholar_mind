enum StudyMaterialType {
  lectureNotes,
  pastYearQuestions,
}

extension StudyMaterialTypeExtension on StudyMaterialType {
  String get title {
    switch (this) {
      case StudyMaterialType.lectureNotes:
        return 'Select Lecture Notes';
      case StudyMaterialType.pastYearQuestions:
        return 'Select Past Year Questions';
    }
  }
}