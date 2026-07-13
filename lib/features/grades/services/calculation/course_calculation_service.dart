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

    double expectedWeight = 0;

    double guaranteedPercentage = 0;

    double projectedPercentage = 0;

    final completedComponents =
    <GradingComponentModel>[];

    final expectedComponents =
    <GradingComponentModel>[];

    final remainingComponents =
    <GradingComponentModel>[];

    final actualEntries =
    assessments
        .where(
          (entry) =>
      entry.type ==
          AssessmentType.actual,
    )
        .toList();

    final expectedEntries =
    assessments
        .where(
          (entry) =>
      entry.type ==
          AssessmentType.expected,
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

        final actualAssessment =
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

        final expectedAssessment =
        expectedEntries
            .where(
              (entry) =>
          entry.componentId ==
              target.id,
        )
            .isEmpty
            ? null
            : expectedEntries
            .where(
              (entry) =>
          entry.componentId ==
              target.id,
        )
            .first;

        if (actualAssessment == null &&
            expectedAssessment == null) {

          remainingComponents.add(
            target,
          );

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

        if (actualAssessment != null) {

          completedWeight +=
              overallWeight;

          completedComponents.add(
            target,
          );

          guaranteedPercentage +=
              overallWeight *
                  actualAssessment
                      .percentage /
                  100;

          projectedPercentage +=
              overallWeight *
                  actualAssessment
                      .percentage /
                  100;

        } else {

          expectedWeight +=
              overallWeight;

          expectedComponents.add(
            target,
          );

          projectedPercentage +=
              overallWeight *
                  expectedAssessment!
                      .percentage /
                  100;
        }
      }
    }

    final remainingWeight =
        totalWeight -
        completedWeight;

    final remainingOpportunity =
        remainingWeight;

    final maximumPossiblePercentage =
        guaranteedPercentage +
            remainingOpportunity;

    return CourseCalculationSummary(
      totalWeight: totalWeight,
      completedWeight:
      completedWeight,
      remainingWeight:
      remainingWeight,
      guaranteedPercentage:
      guaranteedPercentage,
      projectedPercentage:
      projectedPercentage,
      maximumPossiblePercentage:
      maximumPossiblePercentage,
      remainingOpportunity:
      remainingOpportunity,
      actualEntries:
      actualEntries,
      expectedEntries:
      expectedEntries,
      completedComponents:
      completedComponents,
      expectedComponents:
      expectedComponents,
      remainingComponents:
      remainingComponents,
    );
  }
}