import '../../../data_sharing/collection/data_share_collector.dart';
import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/collection/collection_result.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/course_repository.dart';
import '../repositories/grading_component_repository.dart';
import '../repositories/semester_repository.dart';

class GradesCollectionService
    implements DataShareCollector {
  GradesCollectionService({
    required this.semesterRepository,
    required this.courseRepository,
    required this.componentRepository,
    required this.assessmentRepository,
  });

  final SemesterRepository semesterRepository;

  final CourseRepository courseRepository;

  final GradingComponentRepository componentRepository;

  final AssessmentRepository assessmentRepository;

  @override
  ShareResourceType get resourceType => ShareResourceType.gradeSemester;

  @override
  Future<CollectionResult> collect({
    required String userId,
    required List<String> resourceIds,
  }) async {
    final resources = <CollectedResource>[];

    for (final semesterId in resourceIds) {
      final semester = await semesterRepository.getSemester(
        semesterId,
      );

      if (semester == null) {
        continue;
      }

      resources.add(
        CollectedResource(
          resourceType: ShareResourceType.gradeSemester,
          resourceId: semester.id,
          data: semester,
        ),
      );

      final courses = await courseRepository.getSemesterCourses(
        semester.id,
      );

      for (final course in courses) {
        resources.add(
          CollectedResource(
            resourceType: ShareResourceType.gradeCourse,
            resourceId: course.id,
            data: course,
          ),
        );

        final components =
        await componentRepository.getCourseComponents(
          course.id,
        );

        for (final component in components) {
          resources.add(
            CollectedResource(
              resourceType:
              ShareResourceType.gradingComponent,
              resourceId: component.id,
              data: component,
            ),
          );
        }

        final entries = await assessmentRepository.getEntries(
          course.id,
        );

        for (final entry in entries) {
          resources.add(
            CollectedResource(
              resourceType:
              ShareResourceType.assessmentEntry,
              resourceId: entry.id,
              data: entry,
            ),
          );
        }
      }
    }

    return CollectionResult(resources: resources);
  }
}
