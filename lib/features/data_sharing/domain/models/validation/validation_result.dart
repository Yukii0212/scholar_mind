class ValidationResult {
  const ValidationResult({
    required this.isValid,
    this.warnings = const [],
    this.errors = const [],
  });

  final bool isValid;

  final List<String> warnings;

  final List<String> errors;
}