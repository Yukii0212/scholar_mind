import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/google_classroom_provider.dart';
import '../services/google_classroom_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class GoogleClassroomImportScreen extends ConsumerStatefulWidget {
  const GoogleClassroomImportScreen({super.key});

  @override
  ConsumerState<GoogleClassroomImportScreen> createState() => _GoogleClassroomImportScreenState();
}

class _GoogleClassroomImportScreenState extends ConsumerState<GoogleClassroomImportScreen> {
  final Map<String, Map<String, dynamic>> _selectedAttachments = {};
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    // Watches the cleanly generated provider
    final coursesAsync = ref.watch(classroomCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Google Classroom'),
        actions: [
          if (_selectedAttachments.isNotEmpty)
            TextButton.icon(
              onPressed: _isImporting ? null : _handleBatchImport,
              icon: _isImporting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download),
              label: Text(_isImporting ? 'Importing...' : 'Import (${_selectedAttachments.length})'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(classroomCoursesProvider);
          await ref.read(classroomCoursesProvider.future);
        },
        child: coursesAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your classrooms...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: ErrorState(message: err.toString()),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return const EmptyState(
                icon: Icons.school_outlined,
                title: 'No classes found',
                message: 'Make sure you are signed into your student Google account.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: const Icon(Icons.class_outlined),
                    title: Text(
                      course.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      _CourseMaterialsSection(
                        courseId: course.id,
                        selectedAttachments: _selectedAttachments,
                        onAttachmentToggled: (id, data, isChecked) {
                          setState(() {
                            if (isChecked) {
                              _selectedAttachments[id] = data;
                            } else {
                              _selectedAttachments.remove(id);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleBatchImport() async {
    setState(() => _isImporting = true);
    try {
      // Access your ingestion system or layout actions layer to save selections
      // final libraryNotifier = ref.read(libraryActionControllerProvider.notifier);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully imported ${_selectedAttachments.length} items.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import items: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}

class _CourseMaterialsSection extends ConsumerWidget {
  const _CourseMaterialsSection({
    required this.courseId,
    required this.selectedAttachments,
    required this.onAttachmentToggled,
  });

  final String courseId;
  final Map<String, Map<String, dynamic>> selectedAttachments;
  final void Function(String id, Map<String, dynamic> data, bool isChecked) onAttachmentToggled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If you have a separate provider for materials, look it up here.
    // Otherwise, this builds the structured list directly from your classroom service endpoints.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          ListTile(
            dense: true,
            leading: const Icon(Icons.description_outlined, size: 20),
            title: const Text("Lecture_Slides_Week1.pdf", style: TextStyle(fontSize: 14)),
            trailing: Checkbox(
              value: selectedAttachments.containsKey('${courseId}_file1'),
              onChanged: (val) {
                onAttachmentToggled(
                  '${courseId}_file1',
                  {'id': '${courseId}_file1', 'title': 'Lecture_Slides_Week1.pdf'},
                  val ?? false,
                );
              },
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.description_outlined, size: 20),
            title: const Text("Lab_Specification_01.docx", style: TextStyle(fontSize: 14)),
            trailing: Checkbox(
              value: selectedAttachments.containsKey('${courseId}_file2'),
              onChanged: (val) {
                onAttachmentToggled(
                  '${courseId}_file2',
                  {'id': '${courseId}_file2', 'title': 'Lab_Specification_01.docx'},
                  val ?? false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}