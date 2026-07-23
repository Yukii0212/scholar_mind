import 'package:flutter/material.dart';

import '../../../core/app_tasks/domain/app_task.dart';
import '../../../core/app_tasks/domain/app_task_status.dart';
import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/providers/app_task_provider.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../data/quiz_library_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_generation_request.dart';
import '../domain/quiz_response.dart';
import '../providers/quiz_attempt_provider.dart';
import '../services/openai_quiz_service.dart';
import '../services/quiz_generation_service.dart';
import 'quiz_viewer_screen.dart';
import '../services/quiz_prompt_builder.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizGeneratingScreen extends ConsumerStatefulWidget {
  const QuizGeneratingScreen({
    super.key,
    required this.request,
    required this.destinationFolderId,
  });

  final QuizGenerationRequest request;

  final String destinationFolderId;

  @override
  ConsumerState<QuizGeneratingScreen>
  createState() =>
      _QuizGeneratingScreenState();
}

class _QuizGeneratingScreenState
    extends ConsumerState<QuizGeneratingScreen> {

  final _generationService =
  const QuizGenerationService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
      ref.read(appTaskProvider.notifier);

      if (!controller.isRunning) {
        _generateQuiz();
      }
    });
  }

  Future<void> _generateQuiz() async {

    final taskController =
    ref.read(
      appTaskControllerProvider,
    );

    try {

      final attempt =
      await taskController.run(
        id: 'quiz_generation',
        type: AppTaskType.quizGeneration,
        title: 'Generating Quiz',
        task: () async {
          return _generationService.generate(
            request: widget.request,
            destinationFolderId:
            widget.destinationFolderId,
          );
        },
      );

      await ref
          .read(
        quizAttemptProvider.notifier,
      )
          .startAttempt(
        attempt,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              QuizViewerScreen(
                attempt: attempt,
              ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Generating Quiz',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'Continue Using ScholarMind',
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Quiz generation will continue while you use the app.',
              textAlign: TextAlign.center,
            ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}