import '../../data/models/assessment_entry_model.dart';
import '../../data/models/grading_component_model.dart';

class CourseCalculationPrediction {
  const CourseCalculationPrediction({
    required this.assessmentPercentage,
    required this.finalPercentage,
    this.isHighlighted = false,
  });

  final double assessmentPercentage;

  final double finalPercentage;

  final bool isHighlighted;
}

class CourseCalculationTarget {
  const CourseCalculationTarget({
    required this.component,
    required this.overallWeight,
  });

  final GradingComponentModel component;

  final double overallWeight;
}

class CourseCalculationSummary {
  const CourseCalculationSummary({
    required this.totalWeight,
    required this.completedWeight,
    required this.remainingWeight,
    required this.guaranteedPercentage,
    required this.projectedPercentage,
    required this.maximumPossiblePercentage,
    required this.remainingOpportunity,
    required this.actualEntries,
    required this.expectedEntries,
    required this.completedComponents,
    required this.expectedComponents,
    required this.remainingComponents,
    required this.remainingTargets,
  });

  final double totalWeight;

  final double completedWeight;

  final double remainingWeight;

  final double guaranteedPercentage;

  final double projectedPercentage;

  final double maximumPossiblePercentage;

  final double remainingOpportunity;

  final List<AssessmentEntryModel> actualEntries;

  final List<AssessmentEntryModel> expectedEntries;

  final List<GradingComponentModel>
  completedComponents;

  final List<GradingComponentModel>
  expectedComponents;

  final List<GradingComponentModel>
  remainingComponents;

  final List<CourseCalculationTarget>
  remainingTargets;

  bool get hasScores =>
      actualEntries.isNotEmpty;

  bool get hasExpectedScores =>
      expectedEntries.isNotEmpty;

  bool get canCalculateRequiredScore =>
      remainingTargets.length == 1;

  CourseCalculationTarget?
  get remainingTarget =>
      canCalculateRequiredScore
          ? remainingTargets.first
          : null;

  double get completedProgress {
    if (totalWeight == 0) {
      return 0;
    }

    return completedWeight /
        totalWeight *
        100;
  }

  double? requiredPercentageFor(
      double targetPercentage,
      ) {
    if (!canCalculateRequiredScore) {
      return null;
    }

    final remaining =
    remainingTarget!;

    final needed =
        (targetPercentage -
            projectedPercentage) /
            remaining.overallWeight *
            100;

    return needed.clamp(
      0,
      100,
    );
  }

  bool isAchievable(
      double targetPercentage,
      ) {
    return maximumPossiblePercentage >=
        targetPercentage;
  }

  List<CourseCalculationPrediction>
  predictionTableFor(
      double targetPercentage, {
        int preferredRows = 9,
        double step = 5,
      }) {

    if (!canCalculateRequiredScore) {
      return [];
    }

    final required =
    requiredPercentageFor(targetPercentage);

    if (required == null) {
      return [];
    }

    final remaining = remainingTarget!;

    int rows = preferredRows;

    while (rows > 3) {

      final half =
          (rows - 1) ~/ 2;

      final start =
          required - half * step;

      final end =
          required + half * step;

      if (start >= 0 &&
          end <= 100) {
        break;
      }

      rows -= 2;
    }

    rows = rows.clamp(3, preferredRows);

    final half =
        (rows - 1) ~/ 2;

    double start =
        required - half * step;

    if (start < 0) {
      start = 0;
    }

    final maxStart =
        100 - (rows - 1) * step;

    if (start > maxStart) {
      start = maxStart;
    }

    start = start.clamp(
      0,
      100,
    );

    final highlighted =
    ((required - start) / step)
        .round();

    final predictions =
    <CourseCalculationPrediction>[];

    for (int i = 0; i < rows; i++) {

      final assessment =
          start + step * i;

      final overall =
          projectedPercentage +
              assessment /
                  100 *
                  remaining.overallWeight;

      predictions.add(
        CourseCalculationPrediction(
          assessmentPercentage:
          assessment,
          finalPercentage:
          overall,
          isHighlighted:
          i == highlighted,
        ),
      );
    }

    return predictions;
  }
}