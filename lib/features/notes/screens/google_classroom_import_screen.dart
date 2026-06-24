import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/google_classroom_provider.dart';
import '../providers/library_provider.dart';
import '../domain/note_category.dart';
import '../services/google_classroom_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class GoogleClassroomImportScreen
    extends ConsumerStatefulWidget {

  const GoogleClassroomImportScreen({
    super.key,
    required this.defaultFolderId,
  });

  final String defaultFolderId;

  @override
  ConsumerState<GoogleClassroomImportScreen>
  createState() =>
      _GoogleClassroomImportScreenState();
}

class _GoogleClassroomImportScreenState extends ConsumerState<GoogleClassroomImportScreen> {
  final Map<String, Map<String, dynamic>> _selectedAttachments = {};
  bool _isImporting = false;

  late String _destinationFolderId;

  @override
  void initState() {
    super.initState();

    _destinationFolderId =
        widget.defaultFolderId;
  }

  @override
  Widget build(BuildContext context) {
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
    setState(() {
      _isImporting = true;
    });

    try {
      final controller =
      ref.read(
        libraryActionControllerProvider
            .notifier,
      );

      var importedCount = 0;

      for (final file
      in _selectedAttachments.values) {

        final fileName =
        file['title'] as String;

        final extension =
        fileName.contains('.')
            ? fileName.split('.').last
            : 'txt';

        final fakeBytes =
        Uint8List.fromList(
          utf8.encode(
            'Google Classroom Import Placeholder',
          ),
        );

        final success =
        await controller.uploadNote(
          folderId: _destinationFolderId,
          fileName: fileName,
          extension: extension,
          bytes: fakeBytes,
          category:
          NoteCategory.selfStudyNotes,
        );

        if (success) {
          importedCount++;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Imported $importedCount files.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Import failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
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
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final materialsAsync =
    ref.watch(
      classroomMaterialsProvider(
        courseId,
      ),
    );

    return materialsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          error.toString(),
        ),
      ),

      data: (materials) {
        if (materials.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No materials found',
            ),
          );
        }

        return Column(
          children: materials.map((material) {
            return ExpansionTile(
              title: Text(material.title),

              children: material.files.map((file) {
                final isSelected =
                selectedAttachments.containsKey(
                  file.id,
                );

                return CheckboxListTile(
                  value: isSelected,

                  title: Text(
                    file.title,
                  ),

                  onChanged: (value) {
                    onAttachmentToggled(
                      file.id,
                      {
                        'id': file.id,
                        'title': file.title,
                      },
                      value ?? false,
                    );
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}