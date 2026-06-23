import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/google_classroom_provider.dart';

class GoogleClassroomImportScreen extends ConsumerStatefulWidget {
  const GoogleClassroomImportScreen({super.key});

  @override
  ConsumerState<GoogleClassroomImportScreen> createState() => _GoogleClassroomImportScreenState();
}

class _GoogleClassroomImportScreenState extends ConsumerState<GoogleClassroomImportScreen> {
  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(classroomCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Google Classroom'),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Failed to load courses: $err', textAlign: TextAlign.center),
          ),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(
              child: Text('No courses found in your Google Classroom.'),
            );
          }
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: const Icon(Icons.class_outlined),
                title: Text(course.name),
                // Removed the non-existent section property to prevent compilation failure
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Ready for sub-component materials view layout placement
                },
              );
            },
          );
        },
      ),
    );
  }
}