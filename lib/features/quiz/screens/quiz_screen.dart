import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/note_item.dart';
import '../../notes/providers/library_provider.dart';

import '../domain/processing_status.dart';
import '../services/study_material_preprocessor.dart';
import '../widgets/generate_quiz_button.dart';
import '../widgets/quiz_configuration_card.dart';
import '../widgets/study_materials_card.dart';
import '../domain/study_material_type.dart';
import 'study_material_picker_screen.dart';

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
                lectureNotesStatus:
                _lectureNotesStatus,
                pastYearQuestionsStatus:
                _pastYearQuestionsStatus,
                onLectureNotesTap:
                _selectLectureNotes,
                onPastYearQuestionsTap:
                _selectPastYearQuestions,
              ),

              SizedBox(height: 20),

              QuizConfigurationCard(),

              SizedBox(height: 32),

              GenerateQuizButton(),
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
}