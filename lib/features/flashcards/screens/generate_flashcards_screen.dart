import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

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
  var _cardCount = 30;
  var _difficulty = 'Intermediate';
  var _generating = false;

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
                          onPressed: _generating || _selectedNoteIds.isEmpty
                              ? null
                              : _generate,
                          icon: _generating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome_rounded),
                          label: Text(
                            _generating
                                ? 'Generating...'
                                : 'Generate Flashcards',
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
    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId == null) return;

    final notesAsync = ref.read(
      allUploadedNotesProvider,
    );

    final notes = notesAsync.valueOrNull;

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

    final selectedNotes = notes
        .where(
          (note) => _selectedNoteIds.contains(note.id),
    )
        .toList(growable: false);

    setState(() => _generating = true);
    try {
      final processed = await _preprocessor.process(selectedNotes);
      final studyContext = await _quizRepository.buildStudyContext(
        lectureNotes: processed.values.toList(),
        pastYearQuestions: const [],
      );
      final generated = await _aiService.generateFlashcards(
        studyContext: studyContext,
        cardCount: _cardCount,
        difficulty: _difficulty,
        extraInstructions: _instructionsController.text,
      );

      await ref.read(flashcardRepositoryProvider).saveGeneratedDeck(
            userId: userId,
            generated: generated,
            tags: _tagsController.text.split(','),
            sourceReference: selectedNotes.map((note) => note.name).join(', '),
            description:
                'Generated from ${selectedNotes.length} study material(s).',
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate flashcards: $error')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
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
    const options = [20, 30, 50, 75, 100];

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Number of Flashcards',
            subtitle: 'Choose how many cards to generate',
          ),
          const Gap(14),
          SegmentedButton<int>(
            segments: [
              for (final option in options)
                ButtonSegment(value: option, label: Text('$option')),
            ],
            selected: {count},
            onSelectionChanged: (value) => onChanged(value.first),
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
    const options = ['Basic', 'Intermediate', 'Advanced', 'Expert'];

    return ScholarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScholarSectionHeader(
            title: 'Difficulty Level',
            subtitle: 'Control the complexity of generated cards',
          ),
          const Gap(14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final option in options)
                ChoiceChip(
                  selected: difficulty == option,
                  onSelected: (_) => onChanged(option),
                  label: Text(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
