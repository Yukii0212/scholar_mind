import '../../data/models/assessment_entry_model.dart';
import '../../data/models/grading_component_model.dart';
import '../../domain/assessment/assessment_type.dart';
import '../../domain/grading/weight_interpreter.dart';

import 'course_calculation_summary.dart';

class CourseCalculationService {
  const CourseCalculationService._();

  static CourseCalculationSummary calculate({
    required List<GradingComponentModel> components,
    required List<AssessmentEntryModel> assessments,
  }) {

    double totalWeight = 0;

    double completedWeight = 0;

    double guaranteedPercentage = 0;

    final actualEntries =
    assessments
        .where(
          (entry) =>
      entry.type ==
          AssessmentType.actual,
    )
        .toList();

    for (final component
    in components.where(
          (e) => e.parentId == null,
    )) {
      totalWeight += component.weight;

      final children =
      components
          .where(
            (e) =>
        e.parentId ==
            component.id,
      )
          .toList();

      final targets =
      children.isEmpty
          ? [component]
          : children;

      for (final target
      in targets) {

        final assessment =
            actualEntries
                .where(
                  (entry) =>
              entry.componentId ==
                  target.id,
            )
                .isEmpty
                ? null
                : actualEntries
                .where(
                  (entry) =>
              entry.componentId ==
                  target.id,
            )
                .first;

        if (assessment == null) {
          continue;
        }

        final overallWeight =
        children.isEmpty
            ? component.weight
            : WeightInterpreter
            .interpret(
          parent: component,
          siblings: children,
          child: target,
        )
            .overallWeight;

        completedWeight +=
            overallWeight;

        guaranteedPercentage +=
            overallWeight *
                assessment.percentage /
                100;
      }
    }

    final remainingWeight =
        totalWeight -
            completedWeight;

    return CourseCalculationSummary(
      totalWeight: totalWeight,
      completedWeight:
      completedWeight,
      remainingWeight:
      remainingWeight,
      guaranteedPercentage:
      guaranteedPercentage,
      maximumPossiblePercentage:
      guaranteedPercentage +
          remainingWeight,
      actualEntries:
      actualEntries,
    );
  }
}