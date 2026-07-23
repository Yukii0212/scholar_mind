import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/note_item.dart';
import '../../notes/providers/library_provider.dart';

import '../domain/processing_status.dart';
import '../domain/assessment_mode.dart';
import '../domain/blooms_level.dart';
import '../services/study_material_preprocessor.dart';
import '../data/quiz_repository.dart';
import '../widgets/generate_quiz_button.dart';
import '../widgets/quiz_configuration_card.dart';
import '../widgets/study_materials_card.dart';
import '../domain/study_material_type.dart';
import '../domain/question_type.dart';
import '../domain/quiz_difficulty.dart';
import '../domain/quiz_generation_request.dart';
import '../../../core/widgets/study_material_picker/study_material_picker_screen.dart';
import 'selection_manager_screen.dart';
import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../providers/quiz_attempt_provider.dart';
import '../services/quiz_generation_service.dart';
import '../domain/question_type_weight.dart';
import '../domain/quiz_folder.dart';
import '../providers/quiz_library_provider.dart' as quiz_library;
import '../widgets/quiz_folder_picker_dialog.dart';

class GenerateQuizScreen extends ConsumerStatefulWidget {
  const GenerateQuizScreen({super.key});

  @override
  ConsumerState<GenerateQuizScreen> createState() =>
      _QuizScreenState();
}

class _QuizScreenState
    extends ConsumerState<GenerateQuizScreen> {

  Set<String> _selectedLectureNotes = {};

  Set<String> _selectedPastYearQuestions = {};

  ProcessingStatus _lectureNotesStatus =
      ProcessingStatus.idle;

  ProcessingStatus _pastYearQuestionsStatus =
      ProcessingStatus.idle;

  final Map<String, ProcessedStudyMaterial>
  _processedLectureNotes = {};

  final Map<String, ProcessedStudyMaterial>
  _processedPastYearQuestions = {};

  final _preprocessor =
  const StudyMaterialPreprocessor();

  final _quizRepository =
  QuizRepository();

  final _generationService =
  const QuizGenerationService();

  String _destinationFolderId = QuizFolder.rootId;

  String _destinationFolderName = 'My Quizzes';

  String? _studyContext;

  int _questionCount = 10;

  AssessmentMode _assessmentMode =
      AssessmentMode.informal;

  QuizDifficulty _difficulty =
      QuizDifficulty.medium;

  BloomsLevel _minimumBloomsLevel =
      BloomsLevel.c1;

  BloomsLevel _maximumBloomsLevel =
      BloomsLevel.c3;

  List<QuestionType> _questionTypes = [
    QuestionType.multipleChoice,
  ];

  String _extraInstructions = '';

  QuestionTypeWeight
  _questionTypeWeight =
  const QuestionTypeWeight(
    multipleChoice: 100,
    trueFalse: 0,
    openEnded: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quiz'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudyMaterialsCard(
                selectedLectureNotes:
                _selectedLectureNotes,
                selectedPastYearQuestions:
                _selectedPastYearQuestions,
                processedLectureNotes:
                _processedLectureNotes.values.toList(),
                processedPastYearQuestions:
                _processedPastYearQuestions.values.toList(),
                lectureNotesStatus:
                _lectureNotesStatus,
                pastYearQuestionsStatus:
                _pastYearQuestionsStatus,
                onLectureNotesTap:
                _selectLectureNotes,
                onPastYearQuestionsTap:
                _selectPastYearQuestions,
                onManageLectureNotesTap:
                _manageLectureNotes,
                onManagePastYearQuestionsTap:
                _managePastYearQuestions,
              ),

              SizedBox(height: 20),

              QuizConfigurationCard(
                questionCount: _questionCount,
                assessmentMode: _assessmentMode,
                difficulty: _difficulty,
                minimumBloomsLevel: _minimumBloomsLevel,
                maximumBloomsLevel: _maximumBloomsLevel,
                questionTypes: _questionTypes,
                questionTypeWeight:
                _questionTypeWeight,
                extraInstructions:
                _extraInstructions,

                onQuestionCountChanged: (value) {
                  setState(() {
                    _questionCount = value;
                  });
                },

                onAssessmentModeChanged: (value) {
                  setState(() {
                    _assessmentMode = value;
                  });
                },

                onDifficultyChanged: (value) {
                  setState(() {
                    _difficulty = value;
                  });
                },

                onMinimumBloomsLevelChanged: (value) {
                  setState(() {
                    _minimumBloomsLevel = value;

                    if (_minimumBloomsLevel.level >
                        _maximumBloomsLevel.level) {
                      _maximumBloomsLevel = value;
                    }
                  });
                },

                onMaximumBloomsLevelChanged: (value) {
                  setState(() {
                    _maximumBloomsLevel = value;

                    if (_maximumBloomsLevel.level <
                        _minimumBloomsLevel.level) {
                      _minimumBloomsLevel = value;
                    }
                  });
                },

                onQuestionTypesChanged: (value) {
                  setState(() {
                    _questionTypes = value;

                    _questionTypeWeight =
                        _rebalanceQuestionTypes(
                          value,
                          _questionTypeWeight,
                        );
                  });
                },

                onQuestionTypeWeightChanged:
                    (value) {
                  setState(() {
                    _questionTypeWeight =
                        value;
                  });
                },

                onExtraInstructionsChanged:
                    (value) {
                  setState(() {
                    _extraInstructions = value;
                  });
                },
              ),

              SizedBox(height: 32),

              Card(
                child: ListTile(

                  leading: const Icon(
                    Icons.folder,
                  ),

                  title: const Text(
                    'Destination',
                  ),

                  subtitle: Text(
                    _destinationFolderName,
                  ),

                  trailing: TextButton(

                    onPressed: () async {

                      final folders = await ref.read(
                        quiz_library.allFoldersProvider.future,
                      );

                      if (!mounted) {
                        return;
                      }

                      final folderId =
                      await showDialog<String>(
                        context: context,
                        builder: (_) {
                          return QuizFolderPickerDialog(
                            folders: folders,
                          );
                        },
                      );

                      if (folderId == null) {
                        return;
                      }

                      final folderName =
                      folderId == QuizFolder.rootId
                          ? 'My Quizzes'
                          : folders
                          .firstWhere(
                            (folder) =>
                        folder.id ==
                            folderId,
                      )
                          .name;

                      setState(() {

                        _destinationFolderId =
                            folderId;

                        _destinationFolderName =
                            folderName;

                      });

                    },

                    child: const Text(
                      'Change',
                    ),

                  ),

                ),
              ),

              const SizedBox(height: 20),
              GenerateQuizButton(
                onPressed: _generateQuiz,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectLectureNotes() async {
    final selected =
    await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudyMaterialPickerScreen(
              type:
              StudyMaterialType.lectureNotes,
              initialSelection:
              _selectedLectureNotes,
            ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection =
        _selectedLectureNotes;

    setState(() {
      _selectedLectureNotes = selected;
    });

    await _processLectureNotes(
      previousSelection,
    );
  }

  QuestionTypeWeight
  _rebalanceQuestionTypes(
      List<QuestionType> types,
      QuestionTypeWeight current,
      ) {
    if (!current.isCustom) {
      switch (types.length) {
        case 1:
          return QuestionTypeWeight(
            multipleChoice: types.contains(QuestionType.multipleChoice) ? 100 : 0,
            trueFalse: types.contains(QuestionType.trueFalse) ? 100 : 0,
            openEnded: types.contains(QuestionType.openEnded) ? 100 : 0,
          );

        case 2:
          var mcq = 0;
          var tf = 0;
          var oe = 0;

          if (types.contains(QuestionType.multipleChoice)) {
            mcq = 50;
          }

          if (types.contains(QuestionType.trueFalse)) {
            tf = 50;
          }

          if (types.contains(QuestionType.openEnded)) {
            oe = 50;
          }

          return QuestionTypeWeight(
            multipleChoice: mcq,
            trueFalse: tf,
            openEnded: oe,
          );

        default:
          return const QuestionTypeWeight(
            multipleChoice: 34,
            trueFalse: 33,
            openEnded: 33,
          );
      }
    }

    final enabled = types.length;
    final base = 100 ~/ enabled;
    var remainder = 100 % enabled;

    var mcq = 0;
    var tf = 0;
    var oe = 0;

    if (types.contains(
        QuestionType.multipleChoice)) {
      mcq = base + (remainder-- > 0 ? 1 : 0);
    }

    if (types.contains(
        QuestionType.trueFalse)) {
      tf = base + (remainder-- > 0 ? 1 : 0);
    }

    if (types.contains(
        QuestionType.openEnded)) {
      oe = base + (remainder-- > 0 ? 1 : 0);
    }

    return QuestionTypeWeight(
      multipleChoice: mcq,
      trueFalse: tf,
      openEnded: oe,
      isCustom: true,
    );
  }

  Future<void> _selectPastYearQuestions() async {
    final selected =
    await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const StudyMaterialPickerScreen(
          type: StudyMaterialType
              .pastYearQuestions,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection =
        _selectedPastYearQuestions;

    setState(() {
      _selectedPastYearQuestions =
          selected;
    });

    await _processPastYearQuestions(
      previousSelection,
    );
  }

  Future<void> _manageLectureNotes() async {
    final selected =
    await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SelectionManagerScreen(
              title: 'Lecture Notes',
              selectedNotes:
              _processedLectureNotes.values
                  .map((e) => e.note)
                  .toList(),
            ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection =
        _selectedLectureNotes;

    setState(() {
      _selectedLectureNotes = selected;
    });

    await _processLectureNotes(
      previousSelection,
    );
  }

  Future<void> _managePastYearQuestions() async {
    final selected =
    await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SelectionManagerScreen(
              title: 'Past Year Questions',
              selectedNotes:
              _processedPastYearQuestions
                  .values
                  .map((e) => e.note)
                  .toList(),
            ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection =
        _selectedPastYearQuestions;

    setState(() {
      _selectedPastYearQuestions =
          selected;
    });

    await _processPastYearQuestions(
      previousSelection,
    );
  }

  Future<List<NoteItem>> _resolveNotes(
      Set<String> ids,
      ) async {
    final notes =
    await ref.read(
      allUploadedNotesProvider.future,
    );

    return notes
        .where(
          (note) => ids.contains(note.id),
    )
        .toList();
  }

  Future<void> _processLectureNotes(
      Set<String> previousSelection,
      ) async {
    setState(() {
      _lectureNotesStatus =
          ProcessingStatus.processing;
    });

    try {
      final removed = previousSelection.difference(
        _selectedLectureNotes,
      );

      for (final id in removed) {
        _processedLectureNotes.remove(id);
      }

      final addedIds =
      _selectedLectureNotes.difference(
        previousSelection,
      );

      if (addedIds.isNotEmpty) {
        final notes =
        await _resolveNotes(addedIds);

        final processed =
        await _preprocessor.process(notes);

        _processedLectureNotes.addAll(processed);
      }

      _studyContext =
      await _quizRepository.buildStudyContext(
        lectureNotes:
        _processedLectureNotes.values.toList(),
        pastYearQuestions:
        _processedPastYearQuestions.values.toList(),
      );

      if (!mounted) return;

      setState(() {
        _lectureNotesStatus =
            ProcessingStatus.completed;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _lectureNotesStatus =
            ProcessingStatus.failed;
      });
    }
  }

  Future<void> _processPastYearQuestions(
      Set<String> previousSelection,
      ) async {
    setState(() {
      _pastYearQuestionsStatus =
          ProcessingStatus.processing;
    });

    try {
      final removed = previousSelection.difference(
        _selectedPastYearQuestions,
      );

      for (final id in removed) {
        _processedPastYearQuestions.remove(id);
      }

      final addedIds =
      _selectedPastYearQuestions.difference(
        previousSelection,
      );

      if (addedIds.isNotEmpty) {
        final notes =
        await _resolveNotes(addedIds);

        final processed =
        await _preprocessor.process(notes);

        _processedPastYearQuestions.addAll(processed);
      }

      _studyContext =
      await _quizRepository.buildStudyContext(
        lectureNotes:
        _processedLectureNotes.values.toList(),
        pastYearQuestions:
        _processedPastYearQuestions.values.toList(),
      );

      if (!mounted) return;

      setState(() {
        _pastYearQuestionsStatus =
            ProcessingStatus.completed;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _pastYearQuestionsStatus =
            ProcessingStatus.failed;
      });
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedLectureNotes.isEmpty &&
        _selectedPastYearQuestions.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one Lecture Note or Past Year Question before generating a quiz.',
          ),
        ),
      );

      return;
    }

    if (_studyContext == null ||
        _studyContext!.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Your study materials are still being processed. Please wait a moment and try again.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    final request =
    QuizGenerationRequest(
      studyContext: _studyContext!,
      questionCount: _questionCount,
      assessmentMode: _assessmentMode,
      difficulty: _difficulty,
      minimumBloomsLevel: _minimumBloomsLevel,
      maximumBloomsLevel: _maximumBloomsLevel,
      questionTypes: _questionTypes,
      questionTypeWeight:
      _questionTypeWeight,
      extraInstructions:
      _extraInstructions,
    );

    final taskController =
    ref.read(appTaskControllerProvider);

    final quizAttemptNotifier =
    ref.read(
      quizAttemptProvider.notifier,
    );

    taskController.run(
      id: 'quiz_generation',
      type: AppTaskType.quizGeneration,
      title: 'Generating Quiz',
      task: (progress) async {
        final attempt =
        await _generationService.generate(
          request: request,
          destinationFolderId:
          _destinationFolderId,
          onProgress: progress,
        );

        await quizAttemptNotifier.startAttempt(
          attempt,
        );

        return attempt;
      },
    );

    if (!mounted) return;

    Navigator.of(context).pop();
  }
}