import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/semester_model.dart';
import '../../screens/semester/semester_overview_screen.dart';
import '../course/empty_course_state.dart';
import '../statistics/semester_statistics_card.dart';

class SemesterDetailBody extends StatelessWidget {
  const SemesterDetailBody({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat('MMM yyyy').format(semester.startDate)} - '
                '${DateFormat('MMM yyyy').format(semester.endDate)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                    const SemesterOverviewScreen(),
                  ),
                );
              },
              child: const Text(
                'View all semesters',
              ),
            ),
          ),

          const SizedBox(height: 24),

          const SemesterStatisticsCard(),

          const SizedBox(height: 24),

          Text(
            'Courses',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          const EmptyCourseState(),
        ],
      ),
    );
  }
}