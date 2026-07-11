import 'package:scholar_mind/features/grades/domain/assessment/score_interpretation.dart';

import '../grading/weight_interpretation.dart';

class ScoreInterpreter {
  const ScoreInterpreter._();

  static ScoreInterpretationResult interpret({
    required double score,
    required double denominator,
    required double componentWeight,
    required double overallWeight,
  }) {

    // Percentage
    if ((denominator - 100).abs() < 0.001) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.percentage,
        percentage: score,
      );
    }

    final matchesComponent =
        (denominator - componentWeight).abs() <
            0.001;

    final matchesOverall =
        (denominator - overallWeight).abs() <
            0.001;

    if (matchesComponent && matchesOverall) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.ambiguous,
        percentage:
        score / denominator * 100,
        requiresConfirmation: true,
      );
    }

    if (matchesComponent) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.componentWeight,
        percentage:
        score / denominator * 100,
      );
    }

    if (matchesOverall) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.overallWeight,
        percentage:
        score / denominator * 100,
      );
    }

    return ScoreInterpretationResult(
      interpretation:
      ScoreInterpretation.custom,
      percentage:
      score / denominator * 100,
    );
  }
}