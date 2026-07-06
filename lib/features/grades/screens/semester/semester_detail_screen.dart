import 'package:flutter/material.dart';
import 'package:scholar_mind/features/grades/screens/semester/semester_overview_screen.dart';

class SemesterDetailScreen extends StatelessWidget {
  const SemesterDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Semester',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          Text(
            'This is where the semester dashboard will live.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                  const SemesterOverviewScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('View All Semesters'),
          ),
        ],
      ),
    );
  }
}