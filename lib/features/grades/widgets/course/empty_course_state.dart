import 'package:flutter/material.dart';

class EmptyCourseState extends StatelessWidget {
  const EmptyCourseState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 48,
            ),

            const SizedBox(height: 16),

            Text(
              'No courses yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Use the + button to add your first course.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}