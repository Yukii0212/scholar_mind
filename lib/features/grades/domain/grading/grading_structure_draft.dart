import 'grading_component_draft.dart';

class GradingStructureDraft {
  GradingStructureDraft({
    List<GradingComponentDraft>? components,
    this.autoBalance = true,
  }) : components = components ?? [];

  final List<GradingComponentDraft> components;

  final bool autoBalance;

  bool get isEmpty => components.isEmpty;

  bool get isNotEmpty => components.isNotEmpty;

  double get totalWeight {
    return components.fold(
      0,
          (sum, component) => sum + component.weight,
    );
  }

  GradingStructureDraft copyWith({
    List<GradingComponentDraft>? components,
    bool? autoBalance,
  }) {
    return GradingStructureDraft(
      components: components ?? List.of(this.components),
      autoBalance:
      autoBalance ?? this.autoBalance,
    );
  }
}