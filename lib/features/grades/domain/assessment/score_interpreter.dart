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

    if (score > denominator) {
      return const ScoreInterpretationResult(
        interpretation: ScoreInterpretation.custom,
        percentage: 0,
        title: 'Invalid score',
        description:
        'The score cannot be greater than the maximum score.',
        isValid: false,
        validationMessage:
        'Score cannot exceed the maximum score.',
      );
    }

    if ((denominator - 100).abs() < 0.001) {
      return ScoreInterpretationResult(
        interpretation: ScoreInterpretation.percentage,
        percentage: score,
        title: 'Detected percentage',
        description:
        'This will be treated as a percentage.',
      );
    }

    final matchesComponent =
        (denominator - componentWeight).abs() < 0.001;

    final matchesOverall =
        (denominator - overallWeight).abs() < 0.001;

    final percentage =
        score / denominator * 100;

    if (matchesComponent && matchesOverall) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.ambiguous,
        percentage: percentage,
        title: 'One more detail needed',
        description:
        'This score could be interpreted in more than one way.',
        requiresConfirmation: true,
      );
    }

    if (matchesComponent) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.componentWeight,
        percentage: percentage,
        title: 'Detected coursework weighting',
        description:
        'This score is relative to the coursework component.',
      );
    }

    if (matchesOverall) {
      return ScoreInterpretationResult(
        interpretation:
        ScoreInterpretation.overallWeight,
        percentage: percentage,
        title: 'Detected final grade weighting',
        description:
        'This score contributes directly to your final course grade.',
      );
    }

    return ScoreInterpretationResult(
      interpretation:
      ScoreInterpretation.custom,
      percentage: percentage,
      title: 'Detected raw marks',
      description:
      'This will be treated as marks and converted automatically.',
    );
  }
}