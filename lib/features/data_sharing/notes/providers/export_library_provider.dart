import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../countdown/domain/countdown_item.dart';
import '../../../countdown/providers/countdown_provider.dart';
import '../../../flashcards/providers/flashcard_provider.dart';
import '../../../grades/providers/course/course_provider.dart';
import '../../../grades/providers/semester/semester_provider.dart';
import '../../../notes/providers/library_provider.dart';
import '../../../quiz/providers/quiz_library_provider.dart'
    as quiz_library;
import '../model/export_item.dart';
import '../model/export_module_group.dart';
import '../../domain/models/export/export_module.dart';
import '../../domain/models/share/share_resource_type.dart';

part 'export_library_provider.g.dart';

@riverpod
Future<List<ExportModuleGroup>> exportLibrary(
    ExportLibraryRef ref,
    ) async {
  final folders = await ref.watch(
    allFoldersProvider.future,
  );

  final notes = await ref.watch(
    allExportableNotesProvider.future,
  );

  final countdowns = await ref.watch(
    countdownsProvider.future,
  );

  final flashcardDecks = await ref.watch(
    flashcardDecksProvider.future,
  );

  final quizFolders = await ref.watch(
    quiz_library.allFoldersProvider.future,
  );

  final quizzes = await ref.watch(
    quiz_library.allQuizzesProvider.future,
  );

  final semesters = await ref.watch(
    semesterStreamProvider.future,
  );

  final courses = await ref.watch(
    courseStreamProvider.future,
  );

  final noteItems = <ExportItem>[
    ...folders.map(
          (folder) => ExportItem(
        id: folder.id,
        name: folder.name,
        type: ShareResourceType.noteFolder,
        module: ExportModule.notes,
        parentId: folder.parentId,
      ),
    ),
    ...notes.map(
          (note) => ExportItem(
        id: note.id,
        name: note.name,
            subtitle: note.extension.isEmpty
                ? null
                : note.extension.toUpperCase(),
        type: ShareResourceType.note,
        module: ExportModule.notes,
        parentId: note.folderId,
      ),
    ),
  ];

  final countdownItems = countdowns
      .map(
        (countdown) => ExportItem(
      id: countdown.id,
      name: countdown.title,
      subtitle: countdown.type.label,
      type: ShareResourceType.countdown,
      module: ExportModule.countdowns,
    ),
  )
      .toList();

  final flashcardItems = flashcardDecks
      .map(
        (deck) => ExportItem(
      id: deck.id,
      name: deck.name,
      subtitle: '${deck.cardCount} card${deck.cardCount == 1 ? '' : 's'}',
      type: ShareResourceType.flashcardDeck,
      module: ExportModule.flashcards,
    ),
  )
      .toList();

  final quizItems = <ExportItem>[
    ...quizFolders.map(
          (folder) => ExportItem(
        id: folder.id,
        name: folder.name,
        type: ShareResourceType.quizFolder,
        module: ExportModule.quizzes,
        parentId: folder.parentId,
      ),
    ),
    ...quizzes.map(
          (quiz) => ExportItem(
        id: quiz.id,
        name: quiz.name,
        subtitle:
        '${quiz.quiz.questions.length} question${quiz.quiz.questions.length == 1 ? '' : 's'}',
        type: ShareResourceType.quiz,
        module: ExportModule.quizzes,
        parentId: quiz.folderId,
      ),
    ),
  ];

  final semesterItems = semesters
      .map(
        (semester) {
      final courseCount = courses
          .where(
            (course) =>
        course.semesterId == semester.id,
      )
          .length;

      return ExportItem(
        id: semester.id,
        name: semester.name,
        subtitle:
        '$courseCount course${courseCount == 1 ? '' : 's'}',
        type: ShareResourceType.gradeSemester,
        module: ExportModule.grades,
      );
    },
  )
      .toList();

  return [
    ExportModuleGroup(
      id: 'notes',
      title: 'Notes',
      description: 'Notes, folders and study materials',
      items: noteItems,
    ),
    ExportModuleGroup(
      id: 'countdowns',
      title: 'Countdowns',
      description: 'Assignments, exams and other deadlines',
      items: countdownItems,
    ),
    ExportModuleGroup(
      id: 'flashcards',
      title: 'Flashcards',
      description: 'Flashcard decks',
      items: flashcardItems,
    ),
    ExportModuleGroup(
      id: 'quizzes',
      title: 'Quizzes',
      description: 'Quiz folders and quizzes',
      items: quizItems,
    ),
    ExportModuleGroup(
      id: 'grades',
      title: 'Grades',
      description: 'Semesters, courses and grade entries',
      items: semesterItems,
    ),
  ];
}