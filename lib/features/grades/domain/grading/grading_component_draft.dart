import 'package:uuid/uuid.dart';

import 'grading_component_type.dart';

class GradingComponentDraft {
  GradingComponentDraft({
    String? id,
    required this.name,
    required this.weight,
    this.type = GradingComponentType.component,
    List<GradingComponentDraft>? children,
  })  : id = id ?? const Uuid().v4(),
        children = children ?? [];

  final String id;

  final String name;

  final double weight;

  final GradingComponentType type;

  final List<GradingComponentDraft> children;

  GradingComponentDraft copyWith({
    String? id,
    String? name,
    double? weight,
    GradingComponentType? type,
    List<GradingComponentDraft>? children,
  }) {
    return GradingComponentDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      type: type ?? this.type,
      children: children ?? List.of(this.children),
    );
  }
}