import '../../data/models/grading_component_model.dart';
import '../../domain/grading/grading_component_draft.dart';
import '../../domain/grading/grading_structure_draft.dart';

class GradingStructureMapper {
  const GradingStructureMapper._();

  static List<GradingComponentModel> toModels({
    required String courseId,
    required GradingStructureDraft draft,
  }) {
    final now = DateTime.now();

    final models = <GradingComponentModel>[];

    for (var i = 0;
    i < draft.components.length;
    i++) {
      _flatten(
        component: draft.components[i],
        courseId: courseId,
        parentId: null,
        order: i,
        createdAt: now,
        updatedAt: now,
        output: models,
      );
    }

    return models;
  }

  static void _flatten({
    required GradingComponentDraft component,
    required String courseId,
    required String? parentId,
    required int order,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<GradingComponentModel> output,
  }) {
    output.add(
      GradingComponentModel(
        id: component.id,
        // Overwritten by GradingComponentRepository before it's persisted.
        ownerId: '',
        courseId: courseId,
        parentId: parentId,
        name: component.name,
        weight: component.weight,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );

    for (var i = 0;
    i < component.children.length;
    i++) {
      _flatten(
        component: component.children[i],
        courseId: courseId,
        parentId: component.id,
        order: i,
        createdAt: createdAt,
        updatedAt: updatedAt,
        output: output,
      );
    }
  }

  static GradingStructureDraft fromModels(
      List<GradingComponentModel> models,
      ) {
    final topLevel = models
        .where(
          (model) => model.parentId == null,
    )
        .toList()
      ..sort(
            (a, b) => a.order.compareTo(
          b.order,
        ),
      );

    return GradingStructureDraft(
      components: topLevel
          .map(
            (component) => _buildTree(
          component,
          models,
        ),
      )
          .toList(),
    );
  }

  static GradingComponentDraft _buildTree(
      GradingComponentModel model,
      List<GradingComponentModel> models,
      ) {
    final children = models
        .where(
          (child) =>
      child.parentId == model.id,
    )
        .toList()
      ..sort(
            (a, b) => a.order.compareTo(
          b.order,
        ),
      );

    return GradingComponentDraft(
      id: model.id,
      name: model.name,
      weight: model.weight,
      children: children
          .map(
            (child) =>
            _buildTree(
              child,
              models,
            ),
      )
          .toList(),
    );
  }
}