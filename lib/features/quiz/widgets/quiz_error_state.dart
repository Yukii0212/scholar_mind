import 'package:flutter/material.dart';

import 'quiz_empty_state.dart';

class QuizErrorState extends StatelessWidget {
  const QuizErrorState({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return QuizEmptyState(
      icon: Icons.error_outline,
      title: 'Could not load quizzes',
      message: message,
    );
  }
}