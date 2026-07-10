import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/grading/grading_structure_draft.dart';
import '../../services/grading/grading_structure_service.dart';

final gradingStructureDraftProvider = StateNotifierProvider<
    GradingStructureDraftNotifier,
    GradingStructureDraft>(
      (ref) => GradingStructureDraftNotifier(),
);

class GradingStructureDraftNotifier
    extends StateNotifier<GradingStructureDraft> {
  GradingStructureDraftNotifier()
      : super(
    GradingStructureDraft(),
  );

  void reset() {
    state = GradingStructureDraft();
  }

  void load(
      GradingStructureDraft draft,
      ) {
    state = draft;
  }

  void addComponent({
    required String name,
  }) {
    state =
        GradingStructureService
            .addComponent(
          state,
          name: name,
        );
  }

  void removeComponent(
      String componentId,
      ) {
    state =
        GradingStructureService.removeComponent(
          state,
          componentId,
        );
  }

  void renameComponent({
    required String componentId,
    required String name,
  }) {
    state =
        GradingStructureService.renameComponent(
          state,
          componentId,
          name,
        );
  }

  void resetDistribution() {
    state = GradingStructureService
        .resetDistribution(state);
  }

  void balanceDistribution() {
    state = GradingStructureService
        .balanceDistribution(state);
  }

  void updateWeight({
    required String componentId,
    required double weight,
  }) {
    state =
        GradingStructureService.updateWeight(
          state,
          componentId: componentId,
          weight: weight,
        );
  }
}