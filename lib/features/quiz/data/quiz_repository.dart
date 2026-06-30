import '../services/study_material_preprocessor.dart';

class QuizRepository {
  const QuizRepository();

  Future<String> buildStudyContext({
    required List<ProcessedStudyMaterial> lectureNotes,
    required List<ProcessedStudyMaterial> pastYearQuestions,
  }) async {
    final buffer = StringBuffer();

    if (lectureNotes.isNotEmpty) {
      buffer.writeln('=== Lecture Notes ===');
      buffer.writeln();

      for (final material in lectureNotes) {
        buffer.writeln(
          'File: ${material.note.name}',
        );
        buffer.writeln();
        buffer.writeln(material.text);
        buffer.writeln();
        buffer.writeln(
          '----------------------------------------',
        );
        buffer.writeln();
      }
    }

    if (pastYearQuestions.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }

      buffer.writeln(
        '=== Past Year Questions ===',
      );
      buffer.writeln();

      for (final material in pastYearQuestions) {
        buffer.writeln(
          'File: ${material.note.name}',
        );
        buffer.writeln();
        buffer.writeln(material.text);
        buffer.writeln();
        buffer.writeln(
          '----------------------------------------',
        );
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }
}