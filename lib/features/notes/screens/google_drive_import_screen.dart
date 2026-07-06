import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  bool _isImporting = false;

  final List<DriveItem> _items = [];

  final List<DriveItem> _navigationStack = [];

  bool _isLoading = true;

  int _currentImport = 0;
  int _totalImports = 0;
  String _currentFileName = '';

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
      return Stack(
        children: [
          Scaffold(
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
                    onPressed:
                    _isImporting ? null : _handleBatchImport,
                    icon: _isImporting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.download),
                    label: Text(
                      _isImporting
                          ? 'Importing...'
                          : 'Import (${_selectedAttachments.length})',
                    ),
                  ),
              ],
            ),
            body: IgnorePointer(
              ignoring: _isImporting,
              child: RefreshIndicator(
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
                              item.id,
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
            ),
          ),

          if (_isImporting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          'Importing $_currentImport / $_totalImports',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
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

        final storagePath =
        await controller.uploadNote(
          folderId: _destinationFolderId,
          fileName: fileName,
          extension: extension,
          bytes: bytes,
          category: NoteCategory.selfStudyNotes,
        );

        if (storagePath != null) {

          importedCount++;

          await FileCacheService.saveBytes(
            storagePath: storagePath,
            fileName: fileName,
            bytes: bytes,
          );
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