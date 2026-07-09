import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/grading/grading_structure_persistence_service.dart';
import 'grading_provider.dart';
import 'grading_structure_draft_provider.dart';

final gradingStructureControllerProvider =
Provider<GradingStructureController>(
      (ref) => GradingStructureController(ref),
);

class GradingStructureController {
  const GradingStructureController(
      this._ref,
      );

  final Ref _ref;

  Future<void> loadCourse(
      String courseId,
      ) async {
    final repository = _ref.read(
      gradingComponentRepositoryProvider,
    );

    final draft =
    await GradingStructurePersistenceService
        .loadCourseOrEmpty(
      courseId: courseId,
      repository: repository,
    );

    _ref
        .read(
      gradingStructureDraftProvider.notifier,
    )
        .load(draft);
  }

  Future<void> saveCourse(
      String courseId,
      ) async {
    final repository = _ref.read(
      gradingComponentRepositoryProvider,
    );

    final draft = _ref.read(
      gradingStructureDraftProvider,
    );

    await GradingStructurePersistenceService
        .saveCourse(
      courseId: courseId,
      draft: draft,
      repository: repository,
    );
  }

  void discard() {
    _ref
        .read(
      gradingStructureDraftProvider.notifier,
    )
        .reset();
  }
}