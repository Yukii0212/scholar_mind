import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notes/providers/library_provider.dart';
import '../../../core/widgets/study_material_picker/study_material_picker_screen.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/study_material_type.dart';
import '../../quiz/services/study_material_preprocessor.dart';
import '../providers/flashcard_provider.dart';
import '../services/openai_flashcard_service.dart';

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

  final Set<String> _selectedNoteIds = {};
  var _cardCount = 15;
  var _difficulty = 'Intermediate';

  @override
  void dispose() {
    _instructionsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                    _SelectedMaterialsPanel(
                      selectedCount:
                      _selectedNoteIds.length,
                      onPressed:
                      _selectStudyMaterials,
                    ),

                    const Gap(16),

                    _CountPanel(
                      count: _cardCount,
                      onChanged: (value) =>
                          setState(() {
                            _cardCount = value;
                          }),
                    ),

                    const Gap(16),

                    _DifficultyPanel(
                      difficulty: _difficulty,
                      onChanged: (value) =>
                          setState(() {
                            _difficulty = value;
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
                          onPressed: _selectedNoteIds.isEmpty
                              ? null
                              : _generate,
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

  Future<void> _selectStudyMaterials() async {
    final selected =
    await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudyMaterialPickerScreen(
              type: StudyMaterialType.lectureNotes,
              initialSelection: _selectedNoteIds,
            )
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedNoteIds
        ..clear()
        ..addAll(selected);
    });
  }

  Future<void> _generate() async {
    final userId =
        ref.read(authStateProvider).valueOrNull?.uid;

    if (userId == null) {
      return;
    }

    final notes =
        ref.read(
          allUploadedNotesProvider,
        ).valueOrNull;

    if (notes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Study materials are still loading. Please try again.',
            ),
          ),
        );
      }

      return;
    }

    final selectedNotes =
    notes
        .where(
          (note) =>
          _selectedNoteIds.contains(note.id),
    )
        .toList(
      growable: false,
    );

    final processed =
    await _preprocessor.process(
      selectedNotes,
    );

    final studyContext =
    await _quizRepository.buildStudyContext(
      lectureNotes:
      processed.values.toList(),
      pastYearQuestions: const [],
    );

    final repository =
    ref.read(
      flashcardRepositoryProvider,
    );

    final taskController =
    ref.read(
      appTaskControllerProvider,
    );

    final tags =
    _tagsController.text.split(',');

    final extraInstructions =
        _instructionsController.text;

    unawaited(
      taskController.run<void>(
        id: 'flashcard_generation',
        type:
        AppTaskType.flashcardGeneration,
        title:
        'Generating Flashcards',
        task: (progress) async {
          progress(
            'Generating flashcards...',
          );

          final generated =
          await _aiService.generateFlashcards(
            studyContext: studyContext,
            cardCount: _cardCount,
            difficulty: _difficulty,
            extraInstructions:
            extraInstructions,
          );

          await repository.saveGeneratedDeck(
            userId: userId,
            generated: generated,
            tags: tags,
            sourceReference:
            selectedNotes
                .map(
                  (e) => e.name,
            )
                .join(', '),
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

class _SelectedMaterialsPanel
    extends StatelessWidget {

  const _SelectedMaterialsPanel({
    required this.selectedCount,
    required this.onPressed,
  });

  final int selectedCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    return ScholarPanel(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          ScholarSectionHeader(
            title: 'Study Materials',
            subtitle:
            '$selectedCount selected',
          ),

          const Gap(14),

          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(
              Icons.folder_open,
            ),
            label: Text(
              selectedCount == 0
                  ? 'Select Study Materials'
                  : 'Change Selection',
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPanel extends StatelessWidget {
  const _CountPanel({
    required this.count,
    required this.onChanged,
  });

  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [5, 10, 15, 20, 25];

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Number of Flashcards',
            subtitle: 'Choose how many cards to generate',
          ),
          const Gap(14),
          DropdownButtonFormField<int>(
            initialValue: count,
            decoration: const InputDecoration(
              labelText: 'Number of Flashcards',
              prefixIcon: Icon(Icons.style_rounded),
            ),
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: Text('$option Flashcards'),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DifficultyPanel extends StatelessWidget {
  const _DifficultyPanel({
    required this.difficulty,
    required this.onChanged,
  });

  final String difficulty;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      'Basic',
      'Intermediate',
      'Advanced',
      'Expert',
    ];

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Difficulty Level',
            subtitle: 'Control the complexity of generated cards',
          ),
          const Gap(14),
          DropdownButtonFormField<String>(
            initialValue: difficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty Level',
              prefixIcon: Icon(Icons.tune_rounded),
            ),
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}