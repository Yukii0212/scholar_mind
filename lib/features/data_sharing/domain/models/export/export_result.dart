class ExportResult {
  const ExportResult({
    required this.success,
    required this.warnings,
    required this.errors,
  });

  final bool success;

  final List<String> warnings;

  final List<String> errors;
}