import '../../data/models/assessment_entry_model.dart';
import '../../data/models/grading_component_model.dart';

class CourseCalculationSummary {
  const CourseCalculationSummary({
    required this.totalWeight,
    required this.completedWeight,
    required this.remainingWeight,
    required this.guaranteedPercentage,
    required this.projectedPercentage,
    required this.maximumPossiblePercentage,
    required this.actualEntries,
    required this.expectedEntries,
    required this.completedComponents,
    required this.expectedComponents,
    required this.remainingComponents,
  });

  final double totalWeight;
  final double completedWeight;
  final double remainingWeight;
  final double guaranteedPercentage;
  final double projectedPercentage;
  final double maximumPossiblePercentage;

  final List<AssessmentEntryModel> actualEntries;

  final List<AssessmentEntryModel> expectedEntries;

  final List<GradingComponentModel>
  completedComponents;

  final List<GradingComponentModel>
  expectedComponents;

  final List<GradingComponentModel>
  remainingComponents;

  bool get hasScores =>
      actualEntries.isNotEmpty;

  bool get hasExpectedScores =>
      expectedEntries.isNotEmpty;

  double get completedProgress {
    if (totalWeight == 0) {
      return 0;
    }

    return completedWeight / totalWeight * 100;
  }
}