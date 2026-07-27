import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/course/course_provider.dart';
import '../../../providers/semester/semester_provider.dart';

class ImportCourseDialog extends ConsumerWidget {
  const ImportCourseDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseStreamProvider);
    final semesters = ref.watch(semesterStreamProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Copy from Existing Course',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                'Select a course to copy.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 24),

              Expanded(
                child: courses.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) =>
                      Center(
                        child: Text(
                          error.toString(),
                        ),
                      ),
                  data: (courses) {
                    return semesters.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stackTrace) => Center(
                        child: Text(error.toString()),
                      ),
                      data: (semesters) {
                        if (courses.isEmpty) {
                          return const Center(
                            child: Text(
                              'No courses available to copy.',
                            ),
                          );
                        }

                        return ListView(
                          children: [
                            for (final semester in semesters) ...[
                              Builder(
                                builder: (_) {
                                  final semesterCourses = courses
                                      .where(
                                        (course) =>
                                    course.semesterId ==
                                        semester.id,
                                  )
                                      .toList();

                                  if (semesterCourses.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return ExpansionTile(
                                    initiallyExpanded: false,
                                    title: Text(
                                      semester.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    children: [
                                      for (final course
                                      in semesterCourses)
                                        ListTile(
                                          leading: const Icon(
                                            Icons.menu_book_outlined,
                                          ),
                                          title: Text(course.name),
                                          subtitle:
                                          course.targetScore == null
                                              ? null
                                              : Text(
                                            'Target Score: '
                                                '${course.targetScore!.toStringAsFixed(0)}%',
                                          ),
                                          onTap: () {
                                            Navigator.pop(
                                              context,
                                              course,
                                            );
                                          },
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}