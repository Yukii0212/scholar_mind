enum ScoreInterpretation {
  percentage,
  componentWeight,
  overallWeight,
  custom,
  ambiguous,
}

class ScoreInterpretationResult {
  const ScoreInterpretationResult({
    required this.interpretation,
    required this.percentage,
    this.requiresConfirmation = false,
  });

  final ScoreInterpretation interpretation;

  /// Always stored internally as 0-100.
  final double percentage;

  final bool requiresConfirmation;
}