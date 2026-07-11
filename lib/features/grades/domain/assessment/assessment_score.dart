import 'package:scholar_mind/features/grades/domain/assessment/score_interpretation.dart';

class AssessmentScore {
  const AssessmentScore({
    required this.score,
    required this.denominator,
    required this.percentage,
    required this.interpretation,
  });

  final double score;

  final double denominator;

  /// Normalised 0–100 value.
  final double percentage;

  final ScoreInterpretation interpretation;

  AssessmentScore copyWith({
    double? score,
    double? denominator,
    double? percentage,
    ScoreInterpretation? interpretation,
  }) {
    return AssessmentScore(
      score: score ?? this.score,
      denominator: denominator ?? this.denominator,
      percentage: percentage ?? this.percentage,
      interpretation:
      interpretation ?? this.interpretation,
    );
  }
}