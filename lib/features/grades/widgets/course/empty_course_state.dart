import 'package:flutter/material.dart';

class EmptyCourseState extends StatelessWidget {
  const EmptyCourseState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 56,
            color: Theme.of(context)
                .colorScheme
                .outline,
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
            'Tap the + button to create your first course.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}