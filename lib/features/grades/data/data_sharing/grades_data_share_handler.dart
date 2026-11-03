import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../../../data_sharing/domain/models/validation/validation_result.dart';
import '../../../data_sharing/registry/data_share_handler.dart';
import '../../../data_sharing/services/hierarchical_import_planner.dart';
import '../../../data_sharing/services/share_resource_validator.dart';
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

class GradesDataShareHandler implements DataShareHandler {
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
    final validator = ShareResourceValidator(
      resource,
      supportedTypes: resourceTypes.toSet(),
    );

    switch (resource.resourceType) {
      case ShareResourceType.gradeSemester:
        final startDate = validator.requireDate('startDate');
        final endDate = validator.requireDate('endDate');

        if (startDate != null &&
            endDate != null &&
            endDate.isBefore(startDate)) {
          validator.addError('semester end date is before its start date.');
        }
        break;
      case ShareResourceType.gradeCourse:
        validator.requireString('semesterId');
        validator.optionalNumber('targetScore');
        validator.optionalNumber('minimumAcceptableScore');
        validator.requireNumber('passingScore', minimum: 0);
        break;
      case ShareResourceType.gradingComponent:
        validator.requireString('courseId');
        validator.optionalString('parentId');
        validator.requireNumber('weight', minimum: 0);
        validator.requireInt('order', minimum: 0);
        break;
      case ShareResourceType.assessmentEntry:
        validator.requireString('courseId');
        validator.requireString('componentId');
        validator.requireAllowedValue(
          'type',
          AssessmentType.values.map((value) => value.name),
        );
        validator.requireNumber('score', minimum: 0);
        validator.requireNumber(
          'denominator',
          minimum: 0,
          allowZero: false,
        );
        validator.requireNumber('percentage', minimum: 0);
        validator.requireAllowedValue(
          'interpretation',
          ScoreInterpretation.values.map((value) => value.name),
        );
        break;
      default:
        break;
    }

    return validator.result();
  }

  @override
  ValidationResult validateImportBatch(List<ShareResource> resources) {
    final semesters = resources
        .where(
          (resource) =>
              resource.resourceType == ShareResourceType.gradeSemester,
        )
        .toList();
    final courses = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.gradeCourse,
        )
        .toList();
    final components = resources
        .where(
          (resource) =>
              resource.resourceType == ShareResourceType.gradingComponent,
        )
        .toList();
    final entries = resources
        .where(
          (resource) =>
              resource.resourceType == ShareResourceType.assessmentEntry,
        )
        .toList();
    final semesterIds =
        semesters.map((resource) => resource.resourceId).toSet();
    final courseById = {
      for (final resource in courses) resource.resourceId: resource,
    };
    final componentById = {
      for (final resource in components) resource.resourceId: resource,
    };
    final errors = <String>[];

    for (final course in courses) {
      if (!semesterIds.contains(course.payload['semesterId'])) {
        errors.add(
          'Course "${course.metadata.displayName}" references a semester '
          'that is not included in the import.',
        );
      }
    }

    for (final component in components) {
      final courseId = component.payload['courseId'] as String;
      final parentId = component.payload['parentId'] as String?;

      if (!courseById.containsKey(courseId)) {
        errors.add(
          'Grading component "${component.metadata.displayName}" references '
          'a course that is not included in the import.',
        );
      }

      if (parentId != null) {
        final parent = componentById[parentId];

        if (parent == null) {
          errors.add(
            'Grading component "${component.metadata.displayName}" '
            'references a parent that is not included in the import.',
          );
        } else if (parent.payload['courseId'] != courseId) {
          errors.add(
            'Grading component "${component.metadata.displayName}" and its '
            'parent belong to different courses.',
          );
        }
      }
    }

    for (final entry in entries) {
      final courseId = entry.payload['courseId'] as String;
      final componentId = entry.payload['componentId'] as String;
      final component = componentById[componentId];

      if (!courseById.containsKey(courseId) || component == null) {
        errors.add(
          'Assessment "${entry.metadata.displayName}" references a course '
          'or component that is not included in the import.',
        );
      } else if (component.payload['courseId'] != courseId) {
        errors.add(
          'Assessment "${entry.metadata.displayName}" references a '
          'component from a different course.',
        );
      }
    }

    try {
      planHierarchicalImport(
        items: components,
        idOf: (resource) => resource.resourceId,
        parentIdOf: (resource) => resource.payload['parentId'] as String? ?? '',
        isRootParent: (parentId) => parentId.isEmpty,
        resourceLabel: 'grading component',
      );
    } on FormatException catch (error) {
      errors.add(error.message.toString());
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  @override
  Future<List<ShareResource>> export({
    required String userId,
    required List<String> resourceIds,
    required String shareId,
    void Function(String message)? onProgress,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    final collected = await _collector.collect(
      userId: userId,
      resourceIds: resourceIds,
    );
    ensureSessionCurrent?.call();

    return collected.resources.map(_exportMapper.toResource).toList();
  }

  @override
  Future<void> import({
    required String userId,
    required List<ShareResource> resources,
    void Function()? ensureSessionCurrent,
  }) async {
    ensureSessionCurrent?.call();
    if (resources.isEmpty) {
      return;
    }

    final semesterMap = <String, String>{};
    final courseMap = <String, String>{};
    final componentMap = <String, String>{};

    final semesters = resources
        .where(
          (resource) =>
              resource.resourceType == ShareResourceType.gradeSemester,
        )
        .toList();

    final courses = resources
        .where(
          (resource) => resource.resourceType == ShareResourceType.gradeCourse,
        )
        .toList();

    final components = resources
        .where(
          (resource) =>
              resource.resourceType == ShareResourceType.gradingComponent,
        )
        .toList();

    final entries = resources
        .where(
          (resource) =>
              resource.resourceType == ShareResourceType.assessmentEntry,
        )
        .toList();

    for (final resource in semesters) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.payloadOf(resource);
      final now = DateTime.now();

      final newSemesterId = await _semesterRepository.importSemester(
        userId,
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
      ensureSessionCurrent?.call();

      semesterMap[resource.resourceId] = newSemesterId;
    }

    for (final resource in courses) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.payloadOf(resource);

      final newSemesterId = semesterMap[payload['semesterId'] as String?];

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
          targetScore: (payload['targetScore'] as num?)?.toDouble(),
          minimumAcceptableScore:
              (payload['minimumAcceptableScore'] as num?)?.toDouble(),
          passingScore: (payload['passingScore'] as num?)?.toDouble() ?? 50,
          createdAt: now,
          updatedAt: now,
        ),
        ownerId: userId,
        semesterId: newSemesterId,
      );
      ensureSessionCurrent?.call();

      courseMap[resource.resourceId] = newCourseId;
    }

    final componentPlan = planHierarchicalImport(
      items: components,
      idOf: (resource) => resource.resourceId,
      parentIdOf: (resource) => resource.payload['parentId'] as String? ?? '',
      isRootParent: (parentId) => parentId.isEmpty,
      resourceLabel: 'grading component',
    );

    for (final resource in componentPlan.orderedItems) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.payloadOf(resource);
      final newCourseId = courseMap[payload['courseId'] as String]!;
      final oldParentId = payload['parentId'] as String?;
      final now = DateTime.now();
      final newComponentId = await _componentRepository.importComponent(
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
        parentId: oldParentId == null ? null : componentMap[oldParentId],
      );
      ensureSessionCurrent?.call();

      componentMap[resource.resourceId] = newComponentId;
    }

    for (final resource in entries) {
      ensureSessionCurrent?.call();
      final payload = _importMapper.payloadOf(resource);

      final newCourseId = courseMap[payload['courseId'] as String?];

      final newComponentId = componentMap[payload['componentId'] as String?];

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
          denominator: (payload['denominator'] as num).toDouble(),
          percentage: (payload['percentage'] as num).toDouble(),
          interpretation: ScoreInterpretation.values.byName(
            payload['interpretation'] as String,
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );
      ensureSessionCurrent?.call();
    }
  }
}
