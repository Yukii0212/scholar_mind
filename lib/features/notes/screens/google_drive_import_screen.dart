import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/providers/app_task_provider.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../domain/drive_item.dart';
import '../providers/google_classroom_provider.dart';
import '../providers/library_provider.dart';
import '../domain/note_category.dart';
import '../services/file_cache_service.dart';
import '../widgets/empty_state.dart';

class GoogleDriveImportScreen
    extends ConsumerStatefulWidget {

  const GoogleDriveImportScreen({
    super.key,
    required this.defaultFolderId,
  });

  final String defaultFolderId;

  @override
  ConsumerState<GoogleDriveImportScreen>
  createState() =>
      _GoogleDriveImportScreenState();
}

class _GoogleDriveImportScreenState extends ConsumerState<GoogleDriveImportScreen> {
  final Map<String, Map<String, dynamic>>
  _selectedAttachments = {};

  final List<DriveItem> _items = [];

  final List<DriveItem> _navigationStack = [];

  bool _isLoading = true;

  late String _destinationFolderId;

  Future<void> _loadFolder(
      String folderId,
      ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await ref
          .read(
        googleClassroomServiceProvider,
      )
          .fetchDriveItems(
        folderId,
      );

      if (!mounted) return;

      setState(() {
        _items
          ..clear()
          ..addAll(items);

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _destinationFolderId =
        widget.defaultFolderId;

    _loadFolder('root');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text(
                _navigationStack.isEmpty
                    ? 'Import from Google Drive'
                    : _navigationStack.last.name,
              ),
              leading: _navigationStack.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _navigationStack.removeLast();
                  });

                  _loadFolder(
                    _navigationStack.isEmpty
                        ? 'root'
                        : _navigationStack.last.id,
                  );
                },
              ),
              actions: [
                if (_selectedAttachments.isNotEmpty)
                  TextButton.icon(
                    onPressed: _handleBatchImport,
                    icon: const Icon(
                      Icons.download,
                    ),
                    label: Text(
                      'Import (${_selectedAttachments.length})',
                    ),
                  ),
              ],
            ),
      body: RefreshIndicator(
                onRefresh: () async {
                  await _loadFolder(
                    _navigationStack.isEmpty
                        ? 'root'
                        : _navigationStack.last.id,
                  );
                },
                child: _isLoading
                    ? const Center(
                  child:
                  CircularProgressIndicator(),
                )
                    : _items.isEmpty
                    ? const EmptyState(
                  icon: Icons.folder_open,
                  title: 'Folder is empty',
                  message:
                  'No files were found.',
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder:
                      (context, index) {
                    final item =
                    _items[index];

                    if (item.isFolder) {
                      return Card(
                        child: ListTile(
                          leading:
                          const Icon(
                            Icons.folder,
                          ),
                          title:
                          Text(item.name),
                          trailing:
                          const Icon(
                            Icons.chevron_right,
                          ),
                          onTap: () {
                            _navigationStack
                                .add(item);

                            _loadFolder(
                              item.effectiveId,
                            );
                          },
                        ),
                      );
                    }

                    final selected =
                    _selectedAttachments
                        .containsKey(
                      item.id,
                    );

                    return CheckboxListTile(
                      value: selected,
                      secondary: Icon(
                        item.isImage
                            ? Icons.image_outlined
                            : Icons.insert_drive_file,
                        color: item.isSupported
                            ? null
                            : Theme.of(context)
                            .disabledColor,
                      ),
                      title: Text(
                        item.name,
                        style: item.isSupported
                            ? null
                            : TextStyle(
                          color: Theme.of(context)
                              .disabledColor,
                        ),
                      ),
                      subtitle: item.isSupported
                          ? null
                          : const Text(
                        'Unsupported file type',
                      ),
                      controlAffinity:
                      ListTileControlAffinity.leading,
                      onChanged: item.isSupported
                          ? (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedAttachments[item.id] = {
                              'id': item.effectiveId,
                              'title': item.name,
                            };
                          } else {
                            _selectedAttachments.remove(
                              item.id,
                            );
                          }
                        });
                      }
                          : (_) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unsupported file type.',
                            ),
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

    final taskController =
    ref.read(
      appTaskControllerProvider,
    );

    final classroomService =
    ref.read(
      googleClassroomServiceProvider,
    );

    final libraryController =
    ref.read(
      libraryActionControllerProvider
          .notifier,
    );

    final attachments =
    _selectedAttachments.values
        .map(
      Map<String, dynamic>.from,
    )
        .toList(
      growable: false,
    );

    final destinationFolderId =
        _destinationFolderId;

    unawaited(
      taskController.run<int>(
        id: 'google_drive_import',
        type: AppTaskType.googleDriveImport,
        title: 'Importing Google Drive Files',
        task: (progress) async {
          return classroomService.importAttachments(
            attachments: attachments,
            destinationFolderId:
            destinationFolderId,
            uploadNote: ({
              required folderId,
              required fileName,
              required extension,
              required bytes,
            }) {
              return libraryController.uploadNote(
                folderId: folderId,
                fileName: fileName,
                extension: extension,
                bytes: bytes,
                category:
                NoteCategory.selfStudyNotes,
              );
            },
            cacheFile: (
                storagePath,
                fileName,
                bytes,
                ) {
              return FileCacheService.saveBytes(
                storagePath: storagePath,
                fileName: fileName,
                bytes: bytes,
              );
            },
            onProgress: progress,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}