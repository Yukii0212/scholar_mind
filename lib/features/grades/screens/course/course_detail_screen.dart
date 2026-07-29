import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/course_model.dart';
import '../../providers/course/course_provider.dart';
import '../../providers/grading/grading_provider.dart';
import '../../widgets/course/course_detail_body.dart';
import 'course_analytics_screen.dart';

/// The course's home screen — assessment entry (scores in/out), reached via
/// "Open" on a course. Analytics is a deliberate, separate destination
/// (the "Analytics" action below), not a mode toggled within this screen:
/// putting them on the same surface made a swipe meant for switching
/// between Overview/Targets/Predictions ambiguous with switching between
/// Assessment/Analytics itself.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  final CourseModel course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hasGradingStructureProvider(course.id));

    final liveCourse = ref.watch(courseProvider(course.id));

    return Scaffold(
      appBar: AppBar(
        title: liveCourse.when(
          loading: () => Text(course.name),
          error: (_, __) => Text(course.name),
          data: (value) => Text(value.name),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CourseAnalyticsScreen(course: course),
              ),
            ),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Analytics'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CourseDetailBody(course: course),
    );
  }
}
