import '../../domain/grading/grading_component_draft.dart';
import '../../domain/grading/grading_structure_draft.dart';

import '../../../../core/algorithms/distribution_balancer.dart';

class GradingStructureService {
  const GradingStructureService._();

  static GradingStructureDraft addComponent(
      GradingStructureDraft draft, {
        required String name,
      }) {
    final components = List<GradingComponentDraft>.from(
      draft.components,
    );

    components.add(
      GradingComponentDraft(
        name: name,
        weight: 0,
      ),
    );

    final balanced =
    DistributionBalancer.equalise(
      itemCount: components.length,
    );

    final updated = <GradingComponentDraft>[];

    for (var i = 0; i < components.length; i++) {
      updated.add(
        components[i].copyWith(
          weight: balanced[i],
        ),
      );
    }

    return draft.copyWith(
      components: updated,
    );
  }

  static GradingStructureDraft removeComponent(
      GradingStructureDraft draft,
      String componentId,
      ) {
    final components =
    draft.components.where(
          (component) =>
      component.id != componentId,
    ).toList();

    if (components.isEmpty) {
      return draft.copyWith(
        components: [],
      );
    }

    final balanced =
    DistributionBalancer.equalise(
      itemCount: components.length,
    );

    final updated = <GradingComponentDraft>[];

    for (var i = 0; i < components.length; i++) {
      updated.add(
        components[i].copyWith(
          weight: balanced[i],
        ),
      );
    }

    return draft.copyWith(
      components: updated,
    );
  }

  static GradingStructureDraft renameComponent(
      GradingStructureDraft draft,
      String componentId,
      String name,
      ) {
    return draft.copyWith(
      components: draft.components
          .map(
            (component) {
          if (component.id != componentId) {
            return component;
          }

          return component.copyWith(
            name: name,
          );
        },
      )
          .toList(),
    );
  }

  static GradingStructureDraft
  updateWeight(
      GradingStructureDraft draft, {
        required String componentId,
        required double weight,
      }) {
    final index =
    draft.components.indexWhere(
          (component) =>
      component.id == componentId,
    );

    if (index == -1) {
      return draft;
    }

    final values = draft.components
        .map(
          (component) => component.weight,
    )
        .toList();

    values[index] = weight;

    final balanced =
    DistributionBalancer
        .rebalanceAfterEdit(
      values: values,
      editedIndex: index,
    );

    final updated = <GradingComponentDraft>[];

    for (var i = 0;
    i < draft.components.length;
    i++) {
      updated.add(
        draft.components[i].copyWith(
          weight: balanced[i],
        ),
      );
    }

    return draft.copyWith(
      components: updated,
    );
  }
}