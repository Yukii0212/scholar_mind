import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notes/domain/note_item.dart';
import '../../notes/providers/library_provider.dart';
import '../../../core/widgets/study_material_picker/study_material_picker_screen.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/assessment_mode.dart';
import '../../quiz/domain/blooms_level.dart';
import '../../quiz/domain/processing_status.dart';
import '../../quiz/domain/quiz_difficulty.dart';
import '../../quiz/domain/study_material_type.dart';
import '../../quiz/screens/selection_manager_screen.dart';
import '../../quiz/services/study_material_preprocessor.dart';
import '../../quiz/widgets/study_materials_card.dart';
import '../providers/flashcard_provider.dart';
import '../services/openai_flashcard_service.dart';
import '../widgets/flashcard_configuration_card.dart';

class GenerateFlashcardsScreen extends ConsumerStatefulWidget {
  const GenerateFlashcardsScreen({super.key});

  @override
  ConsumerState<GenerateFlashcardsScreen> createState() =>
      _GenerateFlashcardsScreenState();
}

class _GenerateFlashcardsScreenState
    extends ConsumerState<GenerateFlashcardsScreen> {
  final _instructionsController = TextEditingController();
  final _tagsController = TextEditingController();
  final _preprocessor = const StudyMaterialPreprocessor();
  final _quizRepository = QuizRepository();
  final _aiService = const OpenAIFlashcardService();

  Set<String> _selectedLectureNotes = {};
  Set<String> _selectedPastYearQuestions = {};

  ProcessingStatus _lectureNotesStatus = ProcessingStatus.idle;
  ProcessingStatus _pastYearQuestionsStatus = ProcessingStatus.idle;

  final Map<String, ProcessedStudyMaterial> _processedLectureNotes = {};
  final Map<String, ProcessedStudyMaterial> _processedPastYearQuestions = {};

  String? _studyContext;

  var _cardCount = 15;
  var _assessmentMode = AssessmentMode.informal;
  var _difficulty = QuizDifficulty.medium;
  var _minimumBloomsLevel = BloomsLevel.c1;
  var _maximumBloomsLevel = BloomsLevel.c3;

  @override
  void dispose() {
    _instructionsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMaterials = _processedLectureNotes.isNotEmpty ||
        _processedPastYearQuestions.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('AI Flashcard Generation'),
      ),
      body: ScholarScaffoldBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StudyMaterialsCard(
                      selectedLectureNotes: _selectedLectureNotes,
                      selectedPastYearQuestions:
                          _selectedPastYearQuestions,
                      processedLectureNotes:
                          _processedLectureNotes.values.toList(),
                      processedPastYearQuestions:
                          _processedPastYearQuestions.values.toList(),
                      lectureNotesStatus: _lectureNotesStatus,
                      pastYearQuestionsStatus: _pastYearQuestionsStatus,
                      onLectureNotesTap: _selectLectureNotes,
                      onPastYearQuestionsTap: _selectPastYearQuestions,
                      onManageLectureNotesTap: _manageLectureNotes,
                      onManagePastYearQuestionsTap:
                          _managePastYearQuestions,
                    ),

                    const Gap(16),

                    FlashcardConfigurationCard(
                      cardCount: _cardCount,
                      materialCharacterCount: _processedLectureNotes.values
                              .fold(0, (sum, m) => sum + m.text.length) +
                          _processedPastYearQuestions.values.fold(
                            0,
                            (sum, m) => sum + m.text.length,
                          ),
                      assessmentMode: _assessmentMode,
                      difficulty: _difficulty,
                      minimumBloomsLevel: _minimumBloomsLevel,
                      maximumBloomsLevel: _maximumBloomsLevel,
                      onCardCountChanged: (value) => setState(() {
                        _cardCount = value;
                      }),
                      onAssessmentModeChanged: (value) => setState(() {
                        _assessmentMode = value;
                      }),
                      onDifficultyChanged: (value) => setState(() {
                        _difficulty = value;
                      }),
                      onMinimumBloomsLevelChanged: (value) => setState(() {
                        _minimumBloomsLevel = value;
                      }),
                      onMaximumBloomsLevelChanged: (value) => setState(() {
                        _maximumBloomsLevel = value;
                      }),
                    ),

                    const Gap(16),

                    ScholarPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScholarSectionHeader(
                            title: 'Additional Instructions',
                            subtitle: 'Optional guidance for the AI',
                          ),
                          const Gap(14),
                          TextField(
                            controller: _instructionsController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  'Focus on definitions, weak topics, examples...',
                            ),
                          ),
                          const Gap(12),
                          TextField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              labelText: 'Deck tags',
                              helperText: 'Separate tags with commas',
                              prefixIcon: Icon(Icons.sell_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: hasMaterials ? _generate : null,
                        icon: const Icon(
                          Icons.auto_awesome_rounded,
                        ),
                        label: const Text(
                          'Generate Flashcards',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<NoteItem>> _resolveNotes(Set<String> ids) async {
    final notes = await ref.read(allUploadedNotesProvider.future);

    return notes.where((note) => ids.contains(note.id)).toList();
  }

  Future<void> _processLectureNotes(Set<String> previousSelection) async {
    setState(() {
      _lectureNotesStatus = ProcessingStatus.processing;
    });

    try {
      final removed = previousSelection.difference(_selectedLectureNotes);

      for (final id in removed) {
        _processedLectureNotes.remove(id);
      }

      final addedIds = _selectedLectureNotes.difference(previousSelection);

      if (addedIds.isNotEmpty) {
        final notes = await _resolveNotes(addedIds);
        final processed = await _preprocessor.process(notes);
        _processedLectureNotes.addAll(processed);
      }

      _studyContext = await _quizRepository.buildStudyContext(
        lectureNotes: _processedLectureNotes.values.toList(),
        pastYearQuestions: _processedPastYearQuestions.values.toList(),
      );

      if (!mounted) return;

      setState(() {
        _lectureNotesStatus = ProcessingStatus.completed;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _lectureNotesStatus = ProcessingStatus.failed;
      });
    }
  }

  Future<void> _processPastYearQuestions(
    Set<String> previousSelection,
  ) async {
    setState(() {
      _pastYearQuestionsStatus = ProcessingStatus.processing;
    });

    try {
      final removed =
          previousSelection.difference(_selectedPastYearQuestions);

      for (final id in removed) {
        _processedPastYearQuestions.remove(id);
      }

      final addedIds =
          _selectedPastYearQuestions.difference(previousSelection);

      if (addedIds.isNotEmpty) {
        final notes = await _resolveNotes(addedIds);
        final processed = await _preprocessor.process(notes);
        _processedPastYearQuestions.addAll(processed);
      }

      _studyContext = await _quizRepository.buildStudyContext(
        lectureNotes: _processedLectureNotes.values.toList(),
        pastYearQuestions: _processedPastYearQuestions.values.toList(),
      );

      if (!mounted) return;

      setState(() {
        _pastYearQuestionsStatus = ProcessingStatus.completed;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _pastYearQuestionsStatus = ProcessingStatus.failed;
      });
    }
  }

  Future<void> _selectLectureNotes() async {
    final selected = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => StudyMaterialPickerScreen(
          type: StudyMaterialType.lectureNotes,
          initialSelection: _selectedLectureNotes,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection = _selectedLectureNotes;

    setState(() {
      _selectedLectureNotes = selected;
    });

    await _processLectureNotes(previousSelection);
  }

  Future<void> _selectPastYearQuestions() async {
    final selected = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => StudyMaterialPickerScreen(
          type: StudyMaterialType.pastYearQuestions,
          initialSelection: _selectedPastYearQuestions,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection = _selectedPastYearQuestions;

    setState(() {
      _selectedPastYearQuestions = selected;
    });

    await _processPastYearQuestions(previousSelection);
  }

  Future<void> _manageLectureNotes() async {
    final selected = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectionManagerScreen(
          title: 'Lecture Notes',
          selectedNotes:
              _processedLectureNotes.values.map((e) => e.note).toList(),
          onAddMore: (current) => Navigator.push<Set<String>>(
            context,
            MaterialPageRoute(
              builder: (_) => StudyMaterialPickerScreen(
                type: StudyMaterialType.lectureNotes,
                initialSelection: current,
              ),
            ),
          ),
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection = _selectedLectureNotes;

    setState(() {
      _selectedLectureNotes = selected;
    });

    await _processLectureNotes(previousSelection);
  }

  Future<void> _managePastYearQuestions() async {
    final selected = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectionManagerScreen(
          title: 'Past Year Questions',
          selectedNotes: _processedPastYearQuestions.values
              .map((e) => e.note)
              .toList(),
          onAddMore: (current) => Navigator.push<Set<String>>(
            context,
            MaterialPageRoute(
              builder: (_) => StudyMaterialPickerScreen(
                type: StudyMaterialType.pastYearQuestions,
                initialSelection: current,
              ),
            ),
          ),
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    final previousSelection = _selectedPastYearQuestions;

    setState(() {
      _selectedPastYearQuestions = selected;
    });

    await _processPastYearQuestions(previousSelection);
  }

  Future<void> _generate() async {
    final userId = ref.read(authStateProvider).valueOrNull?.uid;

    if (userId == null) {
      return;
    }

    if (_studyContext == null || _studyContext!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your study materials are still being processed. Please wait a moment and try again.',
          ),
        ),
      );

      return;
    }

    final selectedNotes = [
      ..._processedLectureNotes.values.map((e) => e.note),
      ..._processedPastYearQuestions.values.map((e) => e.note),
    ];

    final repository = ref.read(flashcardRepositoryProvider);
    final taskController = ref.read(appTaskControllerProvider);

    final tags = _tagsController.text.split(',');
    final extraInstructions = _instructionsController.text;
    final studyContext = _studyContext!;

    unawaited(
      taskController.run<void>(
        id: 'flashcard_generation',
        type: AppTaskType.flashcardGeneration,
        title: 'Generating Flashcards',
        task: (progress) async {
          progress('Generating flashcards...');

          final generated = await _aiService.generateFlashcards(
            studyContext: studyContext,
            cardCount: _cardCount,
            assessmentMode: _assessmentMode,
            difficulty: _difficulty,
            minimumBloomsLevel: _minimumBloomsLevel,
            maximumBloomsLevel: _maximumBloomsLevel,
            extraInstructions: extraInstructions,
          );

          await repository.saveGeneratedDeck(
            userId: userId,
            generated: generated,
            tags: tags,
            sourceReference:
                selectedNotes.map((e) => e.name).join(', '),
            description:
                'Generated from ${selectedNotes.length} study material(s).',
            onProgress: progress,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
