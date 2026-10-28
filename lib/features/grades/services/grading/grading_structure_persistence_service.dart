import '../../data/repositories/grading_component_repository.dart';
import '../../domain/grading/grading_structure_draft.dart';
import 'grading_structure_mapper.dart';

class GradingStructurePersistenceService {
  const GradingStructurePersistenceService._();

  static Future<void> saveCourse({
    required String userId,
    required String courseId,
    required GradingStructureDraft draft,
    required GradingComponentRepository repository,
  }) async {
    final models = GradingStructureMapper.toModels(
      courseId: courseId,
      draft: draft,
    );

    await repository.replaceCourseComponents(
      userId: userId,
      courseId: courseId,
      components: models,
    );
  }

  static Future<GradingStructureDraft> loadCourseOrEmpty({
    required String userId,
    required String courseId,
    required GradingComponentRepository repository,
  }) async {
    final models = await repository.getCourseComponents(userId, courseId);

    if (models.isEmpty) {
      return GradingStructureDraft();
    }

    return GradingStructureMapper.fromModels(
      models,
    );
  }
}
