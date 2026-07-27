import '../../../data_sharing/domain/models/collection/collected_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource.dart';
import '../../../data_sharing/domain/models/share/share_resource_metadata.dart';
import '../../../data_sharing/domain/models/share/share_resource_type.dart';
import '../models/assessment_entry_model.dart';
import '../models/course_model.dart';
import '../models/grading_component_model.dart';
import '../models/semester_model.dart';

class GradesExportMapper {
  const GradesExportMapper();

  ShareResource toResource(
      CollectedResource resource,
      ) {
    switch (resource.resourceType) {
      case ShareResourceType.gradeSemester:
        return _semester(
          resource.asType<SemesterModel>(),
        );

      case ShareResourceType.gradeCourse:
        return _course(
          resource.asType<CourseModel>(),
        );

      case ShareResourceType.gradingComponent:
        return _component(
          resource.asType<GradingComponentModel>(),
        );

      case ShareResourceType.assessmentEntry:
        return _entry(
          resource.asType<AssessmentEntryModel>(),
        );

      default:
        throw UnsupportedError(
          'Unsupported Grades resource: '
              '${resource.resourceType}',
        );
    }
  }

  ShareResource _semester(
      SemesterModel semester,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.gradeSemester,
      resourceVersion: 1,
      resourceId: semester.id,
      metadata: ShareResourceMetadata(
        displayName: semester.name,
        createdAt: semester.createdAt,
        updatedAt: semester.updatedAt,
      ),
      payload: {
        'startDate': semester.startDate.toIso8601String(),
        'endDate': semester.endDate.toIso8601String(),
      },
    );
  }

  ShareResource _course(
      CourseModel course,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.gradeCourse,
      resourceVersion: 1,
      resourceId: course.id,
      metadata: ShareResourceMetadata(
        displayName: course.name,
        createdAt: course.createdAt,
        updatedAt: course.updatedAt,
      ),
      payload: {
        'semesterId': course.semesterId,
        'targetScore': course.targetScore,
        'minimumAcceptableScore': course.minimumAcceptableScore,
        'passingScore': course.passingScore,
      },
    );
  }

  ShareResource _component(
      GradingComponentModel component,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.gradingComponent,
      resourceVersion: 1,
      resourceId: component.id,
      metadata: ShareResourceMetadata(
        displayName: component.name,
        createdAt: component.createdAt,
        updatedAt: component.updatedAt,
      ),
      payload: {
        'courseId': component.courseId,
        'parentId': component.parentId,
        'weight': component.weight,
        'order': component.order,
      },
    );
  }

  ShareResource _entry(
      AssessmentEntryModel entry,
      ) {
    return ShareResource(
      resourceType: ShareResourceType.assessmentEntry,
      resourceVersion: 1,
      resourceId: entry.id,
      metadata: ShareResourceMetadata(
        displayName:
        '${entry.score}/${entry.denominator}',
        createdAt: entry.createdAt,
        updatedAt: entry.updatedAt,
      ),
      payload: {
        'courseId': entry.courseId,
        'componentId': entry.componentId,
        'type': entry.type.name,
        'score': entry.score,
        'denominator': entry.denominator,
        'percentage': entry.percentage,
        'interpretation': entry.interpretation.name,
      },
    );
  }
}
