import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../domain/assessment/assessment_type.dart';
import '../../domain/assessment/score_interpretation.dart';
import '../models/assessment_entry_model.dart';
import '../models/course_model.dart';
import '../models/grading_component_model.dart';
import '../models/semester_model.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/course_repository.dart';
import '../repositories/grading_component_repository.dart';
import '../repositories/semester_repository.dart';
import 'grades_collection_service.dart';
import 'grades_export_mapper.dart';
import 'grades_import_mapper.dart';

class GradesDataShareHandler
    implements DataShareHandler {
  GradesDataShareHandler({
    required GradesCollectionService collector,
    required SemesterRepository semesterRepository,
    required CourseRepository courseRepository,
    required GradingComponentRepository componentRepository,
    required AssessmentRepository assessmentRepository,
    GradesExportMapper? exportMapper,
    GradesImportMapper? importMapper,
  })  : _collector = collector,
        _semesterRepository = semesterRepository,
        _courseRepository = courseRepository,
        _componentRepository = componentRepository,
        _assessmentRepository = assessmentRepository,
        _exportMapper = exportMapper ?? const GradesExportMapper(),
        _importMapper = importMapper ?? const GradesImportMapper();

  final GradesCollectionService _collector;

  final SemesterRepository _semesterRepository;

  final CourseRepository _courseRepository;

  final GradingComponentRepository _componentRepository;

  final AssessmentRepository _assessmentRepository;

  final GradesExportMapper _exportMapper;

  final GradesImportMapper _importMapper;

  @override
  List<ShareResourceType> get resourceTypes => const [
    ShareResourceType.gradeSemester,
    ShareResourceType.gradeCourse,
    ShareResourceType.gradingComponent,
    ShareResourceType.assessmentEntry,
  ];

  @override
  ValidationResult validateExport(
      List<String> resourceIds,
      ) {
    if (resourceIds.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errors: [
          'No semesters selected.',
        ],
      );
    }

    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  ValidationResult validateImport(
      ShareResource resource,
      ) {
    return const ValidationResult(
      isValid: true,
    );
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final collected = await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );

    return collected.resources
        .map(_exportMapper.toResource)
        .toList();
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
  }) async {
    if (resources.isEmpty) {
      return;
    }

    final semesterMap = <String, String>{};
    final courseMap = <String, String>{};
    final componentMap = <String, String>{};

    final semesters = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.gradeSemester,
    )
        .toList();

    final courses = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.gradeCourse,
    )
        .toList();

    final components = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.gradingComponent,
    )
        .toList();

    final entries = resources
        .where(
          (resource) =>
      resource.resourceType ==
          ShareResourceType.assessmentEntry,
    )
        .toList();

    for (final resource in semesters) {
      final payload = _importMapper.payloadOf(resource);
      final now = DateTime.now();

      final newSemesterId = await _semesterRepository.importSemester(
        SemesterModel(
          id: resource.resourceId,
          name: resource.metadata.displayName,
          startDate: DateTime.parse(
            payload['startDate'] as String,
          ),
          endDate: DateTime.parse(
            payload['endDate'] as String,
          ),
          isCurrent: false,
          isManuallyEdited: false,
          isHidden: false,
          createdAt: now,
          updatedAt: now,
        ),
      );

      semesterMap[resource.resourceId] = newSemesterId;
    }

    for (final resource in courses) {
      final payload = _importMapper.payloadOf(resource);

      final newSemesterId =
      semesterMap[payload['semesterId'] as String?];

      if (newSemesterId == null) {
        continue;
      }

      final now = DateTime.now();

      final newCourseId = await _courseRepository.importCourse(
        course: CourseModel(
          id: resource.resourceId,
          ownerId: userId,
          semesterId: newSemesterId,
          name: resource.metadata.displayName,
          targetScore:
          (payload['targetScore'] as num?)?.toDouble(),
          minimumAcceptableScore:
          (payload['minimumAcceptableScore'] as num?)
              ?.toDouble(),
          passingScore:
          (payload['passingScore'] as num?)?.toDouble() ?? 50,
          createdAt: now,
          updatedAt: now,
        ),
        ownerId: userId,
        semesterId: newSemesterId,
      );

      courseMap[resource.resourceId] = newCourseId;
    }

    while (componentMap.length < components.length) {
      var importedAny = false;

      for (final resource in components) {
        if (componentMap.containsKey(resource.resourceId)) {
          continue;
        }

        final payload = _importMapper.payloadOf(resource);

        final newCourseId =
        courseMap[payload['courseId'] as String?];

        if (newCourseId == null) {
          continue;
        }

        final oldParentId = payload['parentId'] as String?;

        final canImport = oldParentId == null ||
            componentMap.containsKey(oldParentId);

        if (!canImport) {
          continue;
        }

        final now = DateTime.now();

        final newComponentId =
        await _componentRepository.importComponent(
          component: GradingComponentModel(
            id: resource.resourceId,
            ownerId: userId,
            courseId: newCourseId,
            parentId: oldParentId,
            name: resource.metadata.displayName,
            weight: (payload['weight'] as num).toDouble(),
            order: payload['order'] as int,
            createdAt: now,
            updatedAt: now,
          ),
          ownerId: userId,
          courseId: newCourseId,
          parentId: oldParentId == null
              ? null
              : componentMap[oldParentId],
        );

        componentMap[resource.resourceId] = newComponentId;
        importedAny = true;
      }

      if (!importedAny) {
        break;
      }
    }

    for (final resource in entries) {
      final payload = _importMapper.payloadOf(resource);

      final newCourseId =
      courseMap[payload['courseId'] as String?];

      final newComponentId =
      componentMap[payload['componentId'] as String?];

      if (newCourseId == null || newComponentId == null) {
        continue;
      }

      final now = DateTime.now();

      await _assessmentRepository.importEntry(
        AssessmentEntryModel(
          id: resource.resourceId,
          courseId: newCourseId,
          componentId: newComponentId,
          type: AssessmentType.values.byName(
            payload['type'] as String,
          ),
          score: (payload['score'] as num).toDouble(),
          denominator:
          (payload['denominator'] as num).toDouble(),
          percentage:
          (payload['percentage'] as num).toDouble(),
          interpretation: ScoreInterpretation.values.byName(
            payload['interpretation'] as String,
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}
