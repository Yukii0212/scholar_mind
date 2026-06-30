import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/note_item.dart';
import '../../notes/providers/library_provider.dart';

import '../domain/processing_status.dart';
import '../services/study_material_preprocessor.dart';
import '../data/quiz_repository.dart';
import '../widgets/generate_quiz_button.dart';
import '../widgets/quiz_configuration_card.dart';
import '../widgets/study_materials_card.dart';
import '../domain/study_material_type.dart';
import '../domain/question_type.dart';
import '../domain/quiz_difficulty.dart';
import '../domain/quiz_generation_request.dart';
import 'study_material_picker_screen.dart';
import 'selection_manager_screen.dart';
import 'quiz_generating_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() =>
      _QuizScreenState();
}

class _QuizScreenState
    extends ConsumerState<QuizScreen> {

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
  const QuizRepository();

  String? _studyContext;

  int _questionCount = 10;

  QuizDifficulty _difficulty =
      QuizDifficulty.medium;

  List<QuestionType> _questionTypes = [
    QuestionType.multipleChoice,
  ];

  String _extraInstructions = '';

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
                difficulty: _difficulty,
                questionTypes: _questionTypes,
                extraInstructions: _extraInstructions,

                onQuestionCountChanged: (value) {
                  setState(() {
                    _questionCount = value;
                  });
                },

                onDifficultyChanged: (value) {
                  setState(() {
                    _difficulty = value;
                  });
                },

                onQuestionTypesChanged: (value) {
                  setState(() {
                    _questionTypes = value;
                  });
                },

                onExtraInstructionsChanged: (value) {
                  setState(() {
                    _extraInstructions = value;
                  });
                },
              ),

              SizedBox(height: 32),

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
      difficulty: _difficulty,
      questionTypes: _questionTypes,
      extraInstructions:
      _extraInstructions,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizGeneratingScreen(
              request: request,
            ),
      ),
    );
  }
}