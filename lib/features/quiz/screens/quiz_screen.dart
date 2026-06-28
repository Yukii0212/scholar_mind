import 'package:flutter/material.dart';

import '../domain/processing_status.dart';
import '../widgets/generate_quiz_button.dart';
import '../widgets/quiz_configuration_card.dart';
import '../widgets/study_materials_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() =>
      _QuizScreenState();
}

class _QuizScreenState
    extends State<QuizScreen> {

  Set<String> _selectedLectureNotes = {};

  Set<String> _selectedPastYearQuestions = {};

  ProcessingStatus _lectureNotesStatus =
      ProcessingStatus.idle;

  ProcessingStatus _pastYearQuestionsStatus =
      ProcessingStatus.idle;

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
}