import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Map<String, Map<String, dynamic>>
  _selectedAttachments = {};

  bool _isImporting = false;

  int _selectedTab = 0;

  Set<String> _hiddenCourseIds = {};

  int _currentImport = 0;
  int _totalImports = 0;
  String _currentFileName = '';

  late String _destinationFolderId;

  @override
  void initState() {
    super.initState();

    _destinationFolderId =
        widget.defaultFolderId;

    _loadHiddenCourses();
  }

  Future<void> _loadHiddenCourses() async {
    final prefs =
    await SharedPreferences.getInstance();

    setState(() {
      _hiddenCourseIds =
          prefs
              .getStringList(
            'hidden_gc_courses',
          )
              ?.toSet() ??
              {};
    });
  }

  Future<void> _hideCourse(
      String courseId,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    _hiddenCourseIds.add(courseId);

    await prefs.setStringList(
      'hidden_gc_courses',
      _hiddenCourseIds.toList(),
    );

    setState(() {});
  }

  Future<void> _unhideCourse(
      String courseId,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    _hiddenCourseIds.remove(courseId);

    await prefs.setStringList(
      'hidden_gc_courses',
      _hiddenCourseIds.toList(),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(classroomCoursesProvider);

    return Stack(
        children: [
    Scaffold(
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
        body: IgnorePointer(
          ignoring: _isImporting,
          child: RefreshIndicator(
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

            final activeCourses =
            courses.where((course) {

              if (course.courseState !=
                  'ACTIVE') {
                return false;
              }

              return !_hiddenCourseIds.contains(
                course.id,
              );
            }).toList();

            final hiddenCourses =
            courses.where((course) {

              if (course.courseState ==
                  'ARCHIVED') {
                return true;
              }

              return _hiddenCourseIds.contains(
                course.id,
              );
            }).toList();

            final visibleCourses =
            _selectedTab == 0
                ? activeCourses
                : hiddenCourses;

            if (visibleCourses.isEmpty) {
              return const EmptyState(
                icon: Icons.school_outlined,
                title: 'No classes found',
                message: 'Make sure you are signed into your student Google account.',
              );
            }

            return Column(
              children: [

                Padding(
                  padding:
                  const EdgeInsets.all(12),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label:
                        Text('Active Classes'),
                        icon: Icon(
                          Icons.school,
                        ),
                      ),
                      ButtonSegment(
                        value: 1,
                        label:
                        Text('Hidden Classes'),
                        icon: Icon(
                          Icons.visibility_off,
                        ),
                      ),
                    ],
                    selected: {
                      _selectedTab,
                    },
                    onSelectionChanged:
                        (selection) {
                      setState(() {
                        _selectedTab =
                            selection.first;
                      });
                    },
                  ),
                ),

            Expanded(
            child: ListView.builder(
            padding:
            const EdgeInsets.all(12),
            itemCount:
            visibleCourses.length,
              itemBuilder: (context, index) {
              final course =
              visibleCourses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    trailing: PopupMenuButton(
                      itemBuilder: (context) {

                        if (_selectedTab == 0) {
                          return [
                            const PopupMenuItem(
                              value: 'hide',
                              child: Text(
                                'Hide Course',
                              ),
                            ),
                          ];
                        }

                        return [
                          const PopupMenuItem(
                            value: 'unhide',
                            child: Text(
                              'Unhide Course',
                            ),
                          ),
                        ];
                      },

                      onSelected: (value) {
                        if (value == 'hide') {
                          _hideCourse(
                            course.id,
                          );
                        }

                        if (value ==
                            'unhide') {
                          _unhideCourse(
                            course.id,
                          );
                        }
                      },
                    ),
                    leading: const Icon(Icons.class_outlined),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    course.name,
                    style:
                    const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    if (course.courseState !=
                    'ACTIVE')
                      Container(
                      padding:
                      const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                      ),
                      decoration:
                      BoxDecoration(
                      color: Colors.orange,
                      borderRadius:
                      BorderRadius.circular(
                      12,
                      ),
                      ),
                      child: Text(
                      course.courseState,
                      style:
                      const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
            ),
            ),
              ],
            );
          },
        ),
          ),
        ),
    ),
          if (_isImporting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),

                        const SizedBox(height: 16),

                        Text(
                          'Importing $_currentImport / $_totalImports',
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _currentFileName,
                          textAlign:
                          TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
    );
  }

  Future<void> _handleBatchImport() async {
    setState(() {
      _isImporting = true;

      _currentImport = 0;
      _totalImports =
          _selectedAttachments.length;

      _currentFileName = '';
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

        final classroomService =
        ref.read(
          googleClassroomServiceProvider,
        );

        final fileName =
        file['title'] as String;

        setState(() {
          _currentImport++;

          _currentFileName =
              fileName;
        });

        final fileId =
        file['id'] as String;

        final extension =
        fileName.contains('.')
            ? fileName.split('.').last
            : 'txt';

        final bytes =
        await classroomService
            .downloadDriveFile(
          fileId,
        );

        final success =
        await controller.uploadNote(
          folderId: _destinationFolderId,
          fileName: fileName,
          extension: extension,
          bytes: bytes,
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