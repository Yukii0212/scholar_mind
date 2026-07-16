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
    required this.title,
    required this.description,
    this.requiresConfirmation = false,
    this.isValid = true,
    this.validationMessage,
  });

  final ScoreInterpretation interpretation;

  /// Always stored internally as 0-100.
  final double percentage;

  final String title;

  final String description;

  final bool requiresConfirmation;

  final bool isValid;

  final String? validationMessage;
}