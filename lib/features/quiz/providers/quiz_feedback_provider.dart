import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/quiz_feedback_repository.dart';
import '../domain/quiz_feedback_entry.dart';

final quizFeedbackRepositoryProvider = Provider<QuizFeedbackRepository>((ref) {
  return QuizFeedbackRepository(FirebaseFirestore.instance);
});

final quizFeedbackProvider =
    StreamProvider.autoDispose<List<QuizFeedbackEntry>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) {
    return const Stream.empty();
  }

  return ref.watch(quizFeedbackRepositoryProvider).watchFeedback(userId);
});

final quizFeedbackActionControllerProvider =
    AsyncNotifierProvider<QuizFeedbackActionController, void>(
  QuizFeedbackActionController.new,
);

class QuizFeedbackActionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> flagQuestion({
    required String questionText,
    required String questionType,
    String? reason,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    await ref.read(quizFeedbackRepositoryProvider).addFeedback(
          userId: userId,
          questionText: questionText,
          questionType: questionType,
          reason: reason,
        );
  }

  Future<void> deleteFeedback(String feedbackId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    await ref.read(quizFeedbackRepositoryProvider).deleteFeedback(
          userId: userId,
          feedbackId: feedbackId,
        );
  }

  Future<void> clearAll() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    await ref.read(quizFeedbackRepositoryProvider).clearAllFeedback(userId);
  }
}
