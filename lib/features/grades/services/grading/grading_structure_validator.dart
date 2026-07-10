import '../../domain/grading/grading_structure_draft.dart';

class GradingStructureValidationResult {
  const GradingStructureValidationResult({
    required this.isValid,
    required this.errors,
  });

  final bool isValid;
  final List<String> errors;
}

class GradingStructureValidator {
  const GradingStructureValidator._();

  static GradingStructureValidationResult validate(
      GradingStructureDraft draft,
      ) {
    final errors = <String>[];

    if (draft.components.isEmpty) {
      errors.add(
        'Add at least one grading component.',
      );
    }

    final totalWeight = draft.components.fold<double>(
      0,
          (sum, component) =>
      sum + component.weight,
    );

    if ((totalWeight - 100).abs() > 0.001) {
      errors.add(
        'Total weight must equal 100%. '
            'Current total: ${totalWeight.toStringAsFixed(0)}%.',
      );
    }

    for (final component
    in draft.components) {
      if (component.name.trim().isEmpty) {
        errors.add(
          'All grading components must have a name.',
        );
        break;
      }
    }

    return GradingStructureValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}