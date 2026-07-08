import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/course/course_provider.dart';
import '../../../data/models/course_model.dart';

class ImportCourseDialog extends ConsumerWidget {
  const ImportCourseDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseStreamProvider);

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
                'Import Course',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                'Select a course to import.',
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
                    if (courses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No courses available to import.',
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: courses.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final course =
                        courses[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.menu_book_outlined,
                          ),
                          title: Text(
                            course.name,
                          ),
                          subtitle:
                          course.targetGrade ==
                              null
                              ? null
                              : Text(
                            'Target Grade: ${course.targetGrade}',
                          ),
                          onTap: () {
                            Navigator.pop(
                              context,
                              course,
                            );
                          },
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