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

    for (final component in draft.components) {
      if (component.name.trim().isEmpty) {
        errors.add(
          'All grading components must have a name.',
        );
        break;
      }

      if (component.weight <= 0) {
        errors.add(
          '"${component.name}" must have a weight greater than 0%.',
        );
      }

      if (component.children.isEmpty) {
        continue;
      }

      final subcomponentTotal =
      component.children.fold<double>(
        0,
            (sum, child) => sum + child.weight,
      );

      for (final child in component.children) {
        if (child.name.trim().isEmpty) {
          errors.add(
            'Every subcomponent must have a name.',
          );
          break;
        }

        if (child.weight <= 0) {
          errors.add(
            '"${child.name}" must have a weight greater than 0%.',
          );
        }
      }

      final validRelative =
          (subcomponentTotal - 100).abs() < 0.001;

      final validFinal =
          (subcomponentTotal - component.weight)
              .abs() <
              0.001;

      if (!validRelative && !validFinal) {
        errors.add(
          '"${component.name}" subcomponents must total either '
              '100% or '
              '${component.weight.toStringAsFixed(0)}%.',
        );
      }
    }

    return GradingStructureValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}