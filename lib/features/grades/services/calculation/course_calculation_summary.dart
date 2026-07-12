import '../../data/models/assessment_entry_model.dart';

class CourseCalculationSummary {
  const CourseCalculationSummary({
    required this.totalWeight,
    required this.completedWeight,
    required this.remainingWeight,
    required this.guaranteedPercentage,
    required this.maximumPossiblePercentage,
    required this.actualEntries,
  });

  final double totalWeight;

  final double completedWeight;

  final double remainingWeight;

  final double guaranteedPercentage;

  final double maximumPossiblePercentage;

  final List<AssessmentEntryModel> actualEntries;

  bool get hasScores => actualEntries.isNotEmpty;

  double get completedProgress {
    if (totalWeight == 0) {
      return 0;
    }

    return completedWeight / totalWeight * 100;
  }
}