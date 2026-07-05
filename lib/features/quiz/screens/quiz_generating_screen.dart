import 'package:flutter/material.dart';

import '../data/quiz_library_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_folder.dart';
import '../domain/quiz_generation_request.dart';
import '../domain/quiz_response.dart';
import '../providers/quiz_provider.dart';
import '../providers/quiz_attempt_provider.dart';
import '../services/openai_quiz_service.dart';
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

  final _openAIQuizService =
  const OpenAIQuizService();

  final _promptBuilder =
  const QuizPromptBuilder();

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    try {
      final prompt =
      _promptBuilder.build(
        widget.request,
      );
      final result = await Future.wait([
        _openAIQuizService.generateQuiz(
          studyContext: widget.request.studyContext,
          instructions: prompt,
        ),
      ]);

      if (!mounted) return;

      final quiz =
      result.first as QuizResponse;

      final now = DateTime.now();

      final attempt = QuizAttempt(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        quiz: quiz,

        name: quiz.title,

        folderId: widget.destinationFolderId,

        createdAt: now,

        updatedAt: now,

        answers: {},

        status: QuizAttemptStatus.inProgress,

        startedAt: now,
      );

      final repository =
      QuizRepository();

      await repository.saveCurrentAttempt(
        attempt.toJson(),
      );

      final libraryRepository =
      QuizLibraryRepository(
        FirebaseFirestore.instance,
      );

      await libraryRepository.createQuiz(
        userId:
        FirebaseAuth.instance.currentUser!.uid,
        quiz: attempt,
      );

      if (!mounted) return;

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
          builder: (_) => QuizViewerScreen(
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
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),

                SizedBox(height: 32),

                Text(
                  'Generating your AI quiz...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'ScholarMind is reading '
                      'your study materials '
                      'and creating questions.',
                  textAlign:
                  TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}