import 'package:flutter/material.dart';

class GradingWeightInformation
    extends StatelessWidget {
  const GradingWeightInformation({
    super.key,
    required this.parentName,
    required this.componentWeight,
    required this.overallWeight,
  });

  final String parentName;

  final double componentWeight;

  final double overallWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Worth ${componentWeight.toStringAsFixed(0)}% of $parentName',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Contributes ${overallWeight.toStringAsFixed(0)}% to your final grade',
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
      ],
    );
  }
}