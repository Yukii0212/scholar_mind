import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../countdown/data/data_sharing/countdown_collection_service.dart';
import '../../countdown/data/data_sharing/countdown_data_share_handler.dart';
import '../../countdown/providers/countdown_provider.dart';
import '../../flashcards/data/data_sharing/flashcard_collection_service.dart';
import '../../flashcards/data/data_sharing/flashcard_data_share_handler.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../grades/data/data_sharing/grades_collection_service.dart';
import '../../grades/data/data_sharing/grades_data_share_handler.dart';
import '../../grades/providers/assessment/assessment_provider.dart';
import '../../grades/providers/course/course_provider.dart';
import '../../grades/providers/grading/grading_provider.dart';
import '../../grades/providers/semester/semester_provider.dart';
import '../../notes/data/data_sharing/notes_collection_service.dart';
import '../../notes/data/data_sharing/notes_data_share_handler.dart';
import '../../notes/providers/library_provider.dart';
import '../../quiz/data/data_sharing/quiz_collection_service.dart';
import '../../quiz/data/data_sharing/quiz_data_share_handler.dart';
import '../../quiz/providers/quiz_library_provider.dart';
import '../registry/data_share_registry.dart';
import '../services/export_service.dart';

part 'export_service_provider.g.dart';

@riverpod
ExportService exportService(
    ExportServiceRef ref,
    ) {
  final registry = DataShareRegistry.instance;

  final repository = ref.read(
    libraryRepositoryProvider,
  );

  final notesHandler = NotesDataShareHandler(
    repository: repository,
    collector: NotesCollectionService(
      repository: repository,
    ),
  );

  if (registry.handlerFor(
    notesHandler.resourceTypes.first,
  ) ==
      null) {
    registry.register(
      notesHandler,
    );
  }

  final countdownRepository = ref.read(
    countdownRepositoryProvider,
  );

  final countdownHandler = CountdownDataShareHandler(
    repository: countdownRepository,
    collector: CountdownCollectionService(
      repository: countdownRepository,
    ),
  );

  if (registry.handlerFor(
    countdownHandler.resourceTypes.first,
  ) ==
      null) {
    registry.register(
      countdownHandler,
    );
  }

  final flashcardRepository = ref.read(
    flashcardRepositoryProvider,
  );

  final flashcardHandler = FlashcardDataShareHandler(
    repository: flashcardRepository,
    collector: FlashcardCollectionService(
      repository: flashcardRepository,
    ),
  );

  if (registry.handlerFor(
    flashcardHandler.resourceTypes.first,
  ) ==
      null) {
    registry.register(
      flashcardHandler,
    );
  }

  final quizRepository = ref.read(
    quizLibraryRepositoryProvider,
  );

  final quizHandler = QuizDataShareHandler(
    repository: quizRepository,
    collector: QuizCollectionService(
      repository: quizRepository,
    ),
  );

  if (registry.handlerFor(
    quizHandler.resourceTypes.first,
  ) ==
      null) {
    registry.register(
      quizHandler,
    );
  }

  final semesterRepository = ref.read(
    semesterRepositoryProvider,
  );

  final courseRepository = ref.read(
    courseRepositoryProvider,
  );

  final componentRepository = ref.read(
    gradingComponentRepositoryProvider,
  );

  final assessmentRepository = ref.read(
    assessmentRepositoryProvider,
  );

  final gradesHandler = GradesDataShareHandler(
    semesterRepository: semesterRepository,
    courseRepository: courseRepository,
    componentRepository: componentRepository,
    assessmentRepository: assessmentRepository,
    collector: GradesCollectionService(
      semesterRepository: semesterRepository,
      courseRepository: courseRepository,
      componentRepository: componentRepository,
      assessmentRepository: assessmentRepository,
    ),
  );

  if (registry.handlerFor(
    gradesHandler.resourceTypes.first,
  ) ==
      null) {
    registry.register(
      gradesHandler,
    );
  }

  return ExportService();
}