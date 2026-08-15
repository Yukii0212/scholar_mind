import '../../quiz/domain/question_type.dart';
import '../../quiz/domain/quiz_attempt.dart';

class QuestionTypeAccuracy {
  const QuestionTypeAccuracy({
    required this.type,
    required this.correct,
    required this.total,
  });

  final QuestionType type;
  final int correct;
  final int total;

  double? get percentage => total == 0 ? null : (correct / total) * 100;
}

/// One point on the accuracy-over-time chart -- only attempts with at
/// least one objective (MC/TF) question produce a point, since open-ended-
/// only attempts have no percentage to plot on the same axis.
class QuizScorePoint {
  const QuizScorePoint({
    required this.attemptId,
    required this.name,
    required this.date,
    required this.percentage,
  });

  final String attemptId;
  final String name;
  final DateTime date;
  final double percentage;
}

class QuizAnalyticsSummary {
  const QuizAnalyticsSummary({
    required this.totalAttempts,
    required this.completedAttempts,
    required this.totalQuestionsAnswered,
    required this.averageAccuracy,
    required this.accuracyByType,
    required this.flaggedCount,
    required this.scoreTrend,
    required this.essayScore,
    required this.essayMax,
    required this.recentAttempts,
  });

  static const empty = QuizAnalyticsSummary(
    totalAttempts: 0,
    completedAttempts: 0,
    totalQuestionsAnswered: 0,
    averageAccuracy: null,
    accuracyByType: [],
    flaggedCount: 0,
    scoreTrend: [],
    essayScore: 0,
    essayMax: 0,
    recentAttempts: [],
  );

  final int totalAttempts;
  final int completedAttempts;
  final int totalQuestionsAnswered;

  /// Mean of scoreTrend's percentages -- null when no attempt has any
  /// objective questions to score.
  final double? averageAccuracy;

  final List<QuestionTypeAccuracy> accuracyByType;
  final int flaggedCount;

  /// Chronological (oldest first), so charts read left-to-right.
  final List<QuizScorePoint> scoreTrend;

  /// Total AI-graded points earned/available on open-ended questions,
  /// summed across every attempt in range -- the literal marks awarded,
  /// separate from accuracyByType's openEnded entry (which folds it into
  /// a percentage alongside MC/TF for comparison).
  final int essayScore;
  final int essayMax;

  double? get essayPercentage =>
      essayMax == 0 ? null : (essayScore / essayMax) * 100;

  /// Newest-first, already filtered/limited by the aggregator -- so the
  /// UI doesn't need to re-derive "recent within range" itself.
  final List<QuizAttempt> recentAttempts;

  bool get hasData => totalAttempts > 0;
}
