import 'package:flutter/material.dart';

class SemesterStatisticsCard extends StatelessWidget {
  const SemesterStatisticsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Semester statistics placeholder',
          style: Theme.of(context)
              .textTheme
              .titleMedium,
        ),
      ),
    );
  }
}