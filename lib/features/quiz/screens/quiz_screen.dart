import 'package:flutter/material.dart';

import '../widgets/generate_quiz_button.dart';
import '../widgets/quiz_configuration_card.dart';
import '../widgets/study_materials_card.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quiz'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudyMaterialsCard(),

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