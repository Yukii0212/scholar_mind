import 'package:cloud_firestore/cloud_firestore.dart';

import '../../flashcards/domain/flashcard_models.dart';
import '../../quiz/domain/quiz_attempt.dart';
import '../../quiz/domain/question_type.dart';
import '../domain/flashcard_analytics.dart';
import '../domain/quiz_analytics.dart';

/// Pure aggregation -- no Firestore calls here. Takes data already fetched
/// by the app's existing providers/repositories and turns it into the
/// analytics domain summaries.

QuizAnalyticsSummary buildQuizAnalyticsSummary({
  required List<QuizAttempt> attempts,
  required int flaggedCount,
}) {
  if (attempts.isEmpty) return QuizAnalyticsSummary.empty;

  var totalQuestionsAnswered = 0;
  var completedAttempts = 0;
  var totalEssayScore = 0;
  var totalEssayMax = 0;

  final scoreTrend = <QuizScorePoint>[];

  final typeCorrect = <QuestionType, int>{};
  final typeTotal = <QuestionType, int>{};

  for (final attempt in attempts) {
    totalQuestionsAnswered += attempt.answeredCount;

    if (attempt.status != QuizAttemptStatus.completed) continue;
    completedAttempts++;

    var objectiveCorrect = 0;
    var objectiveTotal = 0;
    var essayScore = 0;
    var essayMax = 0;

    for (var i = 0; i < attempt.quiz.questions.length; i++) {
      final answer = attempt.answers[i];

      // Excluded from scoring -- same rule quiz_result_screen.dart uses.
      if (answer?.notImportant == true) continue;

      final question = attempt.quiz.questions[i];

      if (question.type == QuestionType.openEnded) {
        essayScore += answer?.aiScore ?? 0;
        essayMax += answer?.aiMaxScore ?? 0;
        continue;
      }

      objectiveTotal++;
      typeTotal[question.type] = (typeTotal[question.type] ?? 0) + 1;

      if (answer != null &&
          question.correctAnswerIndex != null &&
          answer.selectedOptionIndex == question.correctAnswerIndex) {
        objectiveCorrect++;
        typeCorrect[question.type] = (typeCorrect[question.type] ?? 0) + 1;
      }
    }

    totalEssayScore += essayScore;
    totalEssayMax += essayMax;

    // For openEnded, "total" is summed max AI-graded points rather than a
    // question count, and "correct" is summed points earned -- a different
    // unit than the MC/TF counts above, but percentage (the only thing
    // ever displayed) means the same thing either way: how much of the
    // available credit was earned.
    if (essayMax > 0) {
      typeTotal[QuestionType.openEnded] =
          (typeTotal[QuestionType.openEnded] ?? 0) + essayMax;
      typeCorrect[QuestionType.openEnded] =
          (typeCorrect[QuestionType.openEnded] ?? 0) + essayScore;
    }

    if (objectiveTotal > 0) {
      scoreTrend.add(
        QuizScorePoint(
          attemptId: attempt.id,
          name: attempt.name,
          date: attempt.completedAt ?? attempt.updatedAt,
          percentage: (objectiveCorrect / objectiveTotal) * 100,
        ),
      );
    }
  }

  scoreTrend.sort((a, b) => a.date.compareTo(b.date));

  final averageAccuracy = scoreTrend.isEmpty
      ? null
      : scoreTrend.map((point) => point.percentage).reduce((a, b) => a + b) /
          scoreTrend.length;

  final accuracyByType = QuestionType.values
      .where((type) => (typeTotal[type] ?? 0) > 0)
      .map(
        (type) => QuestionTypeAccuracy(
          type: type,
          correct: typeCorrect[type] ?? 0,
          total: typeTotal[type] ?? 0,
        ),
      )
      .toList();

  return QuizAnalyticsSummary(
    totalAttempts: attempts.length,
    completedAttempts: completedAttempts,
    totalQuestionsAnswered: totalQuestionsAnswered,
    averageAccuracy: averageAccuracy,
    accuracyByType: accuracyByType,
    flaggedCount: flaggedCount,
    scoreTrend: scoreTrend,
    essayScore: totalEssayScore,
    essayMax: totalEssayMax,
    // `attempts` already comes in newest-first (watchAllQuizzes' sort
    // order, preserved by the provider's .where() filter), so no re-sort
    // needed here.
    recentAttempts: attempts.take(10).toList(),
  );
}

FlashcardAnalyticsSummary buildFlashcardAnalyticsSummary({
  required List<FlashcardSet> sets,
  required List<Map<String, dynamic>> rawSessions,
}) {
  if (sets.isEmpty) return FlashcardAnalyticsSummary.empty;

  final sessionTrend = rawSessions
      .map((data) {
        final completedAt = data['completedAt'];

        return FlashcardSessionRecord(
          setId: data['setId'] as String,
          setName: data['setName'] as String,
          reviewed: data['reviewed'] as int? ?? 0,
          known: data['known'] as int? ?? 0,
          needsReview: data['needsReview'] as int? ?? 0,
          completedAt:
              completedAt is Timestamp ? completedAt.toDate() : DateTime.now(),
        );
      })
      .toList()
    ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

  // Derived from sessionTrend (the records actually being shown/filtered),
  // not FlashcardSet's lifetime cumulative counters -- those are always
  // all-time totals, so using them here would make the stat tiles ignore
  // whatever time range the caller already filtered sessionTrend to.
  final totalSessions = sessionTrend.length;
  final totalCardsReviewed =
      sessionTrend.fold<int>(0, (acc, session) => acc + session.reviewed);
  final totalKnown =
      sessionTrend.fold<int>(0, (acc, session) => acc + session.known);
  final totalNeedsReview =
      sessionTrend.fold<int>(0, (acc, session) => acc + session.needsReview);

  final overallKnownRate = (totalKnown + totalNeedsReview) == 0
      ? null
      : (totalKnown / (totalKnown + totalNeedsReview)) * 100;

  final sessionsBySet = <String, List<FlashcardSessionRecord>>{};
  for (final session in sessionTrend) {
    sessionsBySet.putIfAbsent(session.setId, () => []).add(session);
  }

  final perSetBreakdown = sessionsBySet.entries.map((entry) {
    final setSessions = entry.value;
    final matchingSet =
        sets.where((set) => set.id == entry.key).firstOrNull;

    return FlashcardSetBreakdown(
      setId: entry.key,
      setName: setSessions.first.setName,
      cardCount: matchingSet?.cardCount ?? 0,
      sessionsCompleted: setSessions.length,
      knownCards:
          setSessions.fold<int>(0, (acc, session) => acc + session.known),
      needsReviewCards: setSessions.fold<int>(
        0,
        (acc, session) => acc + session.needsReview,
      ),
    );
  }).toList()
    ..sort((a, b) => b.sessionsCompleted.compareTo(a.sessionsCompleted));

  return FlashcardAnalyticsSummary(
    totalSets: sets.length,
    totalSessions: totalSessions,
    totalCardsReviewed: totalCardsReviewed,
    overallKnownRate: overallKnownRate,
    sessionTrend: sessionTrend,
    perSetBreakdown: perSetBreakdown,
  );
}
