import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../controller/share_import_controller.dart';
import '../domain/models/import/import_result.dart';
import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_resource.dart';
import '../providers/share/share_link_service_provider.dart';

class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({
    required this.archive,
    required this.shareId,
    super.key,
  });

  final ShareArchive archive;

  // The share this archive was imported from — used only to record that
  // an import happened (see _import's incrementDownloadCount call), never
  // to re-fetch anything.
  final String shareId;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState
    extends ConsumerState<ImportPreviewScreen> {
  late final List<bool> _selected;

  @override
  void initState() {
    super.initState();

    _selected = List<bool>.filled(
      widget.archive.resources.length,
      true,
    );
  }

  void _import() {
    final resources = <ShareResource>[];

    for (var i = 0; i < widget.archive.resources.length; i++) {
      if (_selected[i]) {
        resources.add(
          widget.archive.resources[i],
        );
      }
    }

    if (resources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one item.',
          ),
        ),
      );
      return;
    }

    final archive = ShareArchive(
      manifest: widget.archive.manifest,
      resources: resources,
    );

    final taskController = ref.read(
      appTaskControllerProvider,
    );

    final importController = ref.read(
      shareImportControllerProvider.notifier,
    );

    unawaited(
      taskController.run<ImportResult>(
        id: 'share_import',
        type: AppTaskType.shareImport,
        title: 'Importing shared materials',
        task: (progress) async {
          final result = await importController.importArchive(
            archive,
          );

          if (!result.success) {
            throw Exception(
              result.errors.join('\n'),
            );
          }

          unawaited(
            ref
                .read(shareLinkServiceProvider)
                .incrementDownloadCount(widget.shareId)
                .catchError((Object error) {
              debugPrint(
                'Could not record import for '
                '${widget.shareId}: $error',
              );
            }),
          );

          return result;
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Importing ${resources.length} item(s) in the background.',
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selected
        .where(
          (selected) => selected,
    )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Import Preview',
        ),
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$selectedCount of ${widget.archive.resources.length} selected',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var i = 0;
                        i < _selected.length;
                        i++) {
                          _selected[i] = true;
                        }
                      });
                    },
                    child: const Text(
                      'Select All',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
              widget.archive.resources.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final resource =
                widget.archive.resources[index];

                final displayName =
                    resource.metadata.displayName;

                return CheckboxListTile(
                  value: _selected[index],
                  onChanged: (value) {
                    setState(() {
                      _selected[index] =
                          value ?? false;
                    });
                  },
                  title: Text(
                    displayName,
                  ),
                  subtitle: Text(
                    resource.resourceType.value,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _import,
                child: const Text(
                  'Import Selected',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
