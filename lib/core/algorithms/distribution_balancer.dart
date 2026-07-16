class DistributionBalancer {
  const DistributionBalancer._();

  static List<double> rebalanceAfterEdit({
    required List<double> values,
    required int editedIndex,
    double targetTotal = 100,
  }) {
    assert(values.isNotEmpty);
    assert(
    editedIndex >= 0 &&
        editedIndex < values.length,
    );

    final result = List<double>.from(values);

    final fixedValue = result[editedIndex];

    final remainingTarget =
        targetTotal - fixedValue;

    if (remainingTarget <= 0) {
      for (var i = 0; i < result.length; i++) {
        if (i == editedIndex) {
          continue;
        }

        result[i] = 0;
      }

      result[editedIndex] = targetTotal;

      return result;
    }

    double remainingCurrent = 0;

    for (var i = 0; i < result.length; i++) {
      if (i == editedIndex) {
        continue;
      }

      remainingCurrent += result[i];
    }

    if (remainingCurrent == 0) {
      final even =
          remainingTarget /
              (result.length - 1);

      for (var i = 0; i < result.length; i++) {
        if (i == editedIndex) {
          continue;
        }

        result[i] = even;
      }

      return result;
    }

    for (var i = 0; i < result.length; i++) {
      if (i == editedIndex) {
        continue;
      }

      result[i] =
          result[i] /
              remainingCurrent *
              remainingTarget;
    }

    return result;
  }

  static List<double> equalise({
    required int itemCount,
    double targetTotal = 100,
  }) {
    if (itemCount <= 0) {
      return [];
    }

    final even = targetTotal / itemCount;

    return List.generate(
      itemCount,
          (_) => even,
    );
  }

  static double round(
      double value,
      ) {
    return double.parse(
      value.toStringAsFixed(2),
    );
  }
}