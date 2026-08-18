import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../quiz/providers/quiz_feedback_provider.dart';
import '../../quiz/providers/quiz_library_provider.dart' as quiz_library;
import '../data/analytics_aggregator.dart';
import '../domain/analytics_time_range.dart';
import '../domain/flashcard_analytics.dart';
import '../domain/quiz_analytics.dart';

/// Shared by both tabs on the Analytics page, so switching between Quiz
/// and Flashcards keeps whatever window the user picked instead of each
/// tab tracking its own.
final analyticsTimeRangeProvider =
    StateProvider<AnalyticsTimeRange>((ref) => AnalyticsTimeRange.allTime);

final quizAnalyticsProvider = Provider<QuizAnalyticsSummary>((ref) {
  final range = ref.watch(analyticsTimeRangeProvider);
  final allAttempts =
      ref.watch(quiz_library.allQuizzesProvider).valueOrNull ?? const [];
  final allFeedback = ref.watch(quizFeedbackProvider).valueOrNull ?? const [];

  final attempts = allAttempts
      .where(
        (attempt) =>
            range.includes(attempt.completedAt ?? attempt.createdAt),
      )
      .toList();

  final flaggedCount =
      allFeedback.where((entry) => range.includes(entry.createdAt)).length;

  return buildQuizAnalyticsSummary(
    attempts: attempts,
    flaggedCount: flaggedCount,
  );
});

final flashcardAnalyticsProvider =
    FutureProvider<FlashcardAnalyticsSummary>((ref) async {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) return FlashcardAnalyticsSummary.empty;

  final range = ref.watch(analyticsTimeRangeProvider);
  final sets = await ref.watch(flashcardSetsProvider.future);

  if (sets.isEmpty) return FlashcardAnalyticsSummary.empty;

  final allSessions = await ref
      .read(flashcardRepositoryProvider)
      .getAllSessions(userId: userId, sets: sets);

  final rawSessions = allSessions.where((data) {
    final completedAt = data['completedAt'];
    if (completedAt is! Timestamp) return true;
    return range.includes(completedAt.toDate());
  }).toList();

  return buildFlashcardAnalyticsSummary(sets: sets, rawSessions: rawSessions);
});
