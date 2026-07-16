import '../../domain/grading/grading_component_draft.dart';
import '../../domain/grading/grading_component_type.dart';
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

  static GradingStructureDraft addSubcomponent(
      GradingStructureDraft draft, {
        required String parentId,
        required String name,
      }) {
    return draft.copyWith(
      components: draft.components.map((component) {
        if (component.id != parentId) {
          return component;
        }

        final children =
        List<GradingComponentDraft>.from(
          component.children,
        );

        children.add(
          GradingComponentDraft(
            name: name,
            weight: 0,
            type: GradingComponentType.subcomponent,
          ),
        );

        return component.copyWith(
          children: children,
        );
      }).toList(),
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

  static GradingStructureDraft removeSubcomponent(
      GradingStructureDraft draft,
      String componentId,
      ) {
    return draft.copyWith(
      components: draft.components.map((component) {
        return component.copyWith(
          children: component.children
              .where(
                (child) =>
            child.id != componentId,
          )
              .toList(),
        );
      }).toList(),
    );
  }

  static GradingStructureDraft resetDistribution(
      GradingStructureDraft draft,
      ) {
    if (draft.components.isEmpty) {
      return draft;
    }

    final balanced =
    DistributionBalancer.equalise(
      itemCount: draft.components.length,
    );

    return draft.copyWith(
      components: [
        for (var i = 0;
        i < draft.components.length;
        i++)
          draft.components[i].copyWith(
            weight: balanced[i],
          ),
      ],
    );
  }

  static GradingStructureDraft balanceDistribution(
      GradingStructureDraft draft,
      ) {
    if (draft.components.isEmpty) {
      return draft;
    }

    final largestIndex = draft.components
        .asMap()
        .entries
        .reduce(
          (a, b) =>
      a.value.weight >= b.value.weight
          ? a
          : b,
    )
        .key;

    final values = draft.components
        .map((e) => e.weight)
        .toList();

    final balanced =
    DistributionBalancer.rebalanceAfterEdit(
      values: values,
      editedIndex: largestIndex,
    );

    return draft.copyWith(
      components: [
        for (var i = 0;
        i < draft.components.length;
        i++)
          draft.components[i].copyWith(
            weight: balanced[i],
          ),
      ],
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

  static GradingStructureDraft renameSubcomponent(
      GradingStructureDraft draft,
      String componentId,
      String name,
      ) {
    return draft.copyWith(
      components: draft.components.map((component) {
        return component.copyWith(
          children: component.children.map((child) {
            if (child.id != componentId) {
              return child;
            }

            return child.copyWith(
              name: name,
            );
          }).toList(),
        );
      }).toList(),
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

    if (!draft.autoBalance) {
      final updated = <GradingComponentDraft>[];

      for (var i = 0;
      i < draft.components.length;
      i++) {
        updated.add(
          draft.components[i].copyWith(
            weight: values[i],
          ),
        );
      }

      return draft.copyWith(
        components: updated,
      );
    }

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

  static GradingStructureDraft
  updateSubcomponentWeight(
      GradingStructureDraft draft, {
        required String componentId,
        required double weight,
      }) {
    return draft.copyWith(
      components: draft.components.map((component) {
        return component.copyWith(
          children: component.children.map((child) {
            if (child.id != componentId) {
              return child;
            }

            return child.copyWith(
              weight: weight,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  static bool validate(
      GradingStructureDraft draft,
      ) {
    for (final component in draft.components) {
      if (component.weight <= 0) {
        return false;
      }

      if (component.children.isEmpty) {
        continue;
      }

      final total =
      component.children.fold<double>(
        0,
            (sum, child) => sum + child.weight,
      );

      final hasZeroWeight =
      component.children.any(
            (child) => child.weight <= 0,
      );

      if (hasZeroWeight) {
        return false;
      }

      if (total != 100 &&
          total != component.weight) {
        return false;
      }
    }

    return true;
  }
}