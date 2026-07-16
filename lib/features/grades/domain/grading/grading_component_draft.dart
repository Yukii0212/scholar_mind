import 'package:uuid/uuid.dart';

import 'grading_component_type.dart';

class GradingComponentDraft {
  GradingComponentDraft({
    String? id,
    required this.name,
    required this.weight,
    this.autoBalance = true,
    this.type = GradingComponentType.component,
    List<GradingComponentDraft>? children,
  })  : id = id ?? const Uuid().v4(),
        children = children ?? [];

  final String id;
  final String name;

  final double weight;

  final bool autoBalance;

  final GradingComponentType type;

  final List<GradingComponentDraft> children;

  GradingComponentDraft copyWith({
    String? id,
    String? name,
    double? weight,
    bool? autoBalance,
    GradingComponentType? type,
    List<GradingComponentDraft>? children,
  }) {
    return GradingComponentDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      autoBalance: autoBalance ?? this.autoBalance,
      type: type ?? this.type,
      children: children ?? List.of(this.children),
    );
  }
}