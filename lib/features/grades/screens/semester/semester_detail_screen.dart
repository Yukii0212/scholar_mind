import 'package:flutter/material.dart';
import 'package:scholar_mind/features/grades/screens/semester/semester_overview_screen.dart';

import 'package:intl/intl.dart';

import '../../data/models/semester_model.dart';
import '../../widgets/semester/rename_semester_dialog.dart';
import 'semester_overview_screen.dart';

class SemesterDetailScreen extends StatelessWidget {
  const SemesterDetailScreen({
    super.key,
    required this.semester,
  });

  final SemesterModel semester;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(semester.name),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    showDialog(
                      context: context,
                      builder: (_) => RenameSemesterDialog(
                        semester: semester,
                      ),
                    );
                    break;

                  case 'edit':
                    break;

                  case 'delete':
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename Semester'),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Duration'),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Semester'),
                ),
              ],
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Course creation coming soon.',
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
        body: SingleChildScrollView(
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
                    builder: (_) => const SemesterOverviewScreen(),
                  ),
                );
              },
              child: const Text('View all semesters'),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Semester statistics placeholder',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Courses',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 16),

          Card(
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the + button to add your first course.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
          ),
        ),
    );
  }
}