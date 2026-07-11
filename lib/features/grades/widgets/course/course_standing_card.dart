import 'package:flutter/material.dart';

class CurrentStandingCard extends StatelessWidget {
  const CurrentStandingCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),

                const SizedBox(width: 12),

                Text(
                  'Current Standing',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'No assessment scores have been entered yet.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Once you begin entering your actual or expected scores, ScholarMind will automatically calculate your current standing, projected final grade and the scores you still need to reach your target.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}