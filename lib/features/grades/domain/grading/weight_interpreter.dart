import '../../data/models/grading_component_model.dart';
import 'weight_interpretation.dart';

class WeightInterpreter {
  const WeightInterpreter._();

  static WeightInterpretation detect(
      GradingComponentModel parent,
      List<GradingComponentModel> children,
      ) {
    final total = children.fold<double>(
      0,
          (sum, child) => sum + child.weight,
    );

    if ((total - 100).abs() < 0.001) {
      return WeightInterpretation.component;
    }

    return WeightInterpretation.overall;
  }

  static WeightInterpretationResult interpret({
    required GradingComponentModel parent,
    required List<GradingComponentModel> siblings,
    required GradingComponentModel child,
  }) {
    final mode = detect(
      parent,
      siblings,
    );

    switch (mode) {
      case WeightInterpretation.component:
        return WeightInterpretationResult(
          componentWeight: child.weight,
          overallWeight:
          parent.weight *
              child.weight /
              100,
          interpretation: mode,
        );

      case WeightInterpretation.overall:
        return WeightInterpretationResult(
          componentWeight:
          child.weight /
              parent.weight *
              100,
          overallWeight: child.weight,
          interpretation: mode,
        );
    }
  }
}