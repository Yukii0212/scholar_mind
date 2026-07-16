enum WeightInterpretation {
  component,
  overall,
}

class WeightInterpretationResult {
  const WeightInterpretationResult({
    required this.componentWeight,
    required this.overallWeight,
    required this.interpretation,
  });

  final double componentWeight;

  final double overallWeight;

  final WeightInterpretation interpretation;
}