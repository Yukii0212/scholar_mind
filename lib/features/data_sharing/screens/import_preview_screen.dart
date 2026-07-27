import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/share_import_controller.dart';
import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_resource.dart';

class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({
    required this.archive,
    super.key,
  });

  final ShareArchive archive;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState
    extends ConsumerState<ImportPreviewScreen> {
  late final List<bool> _selected;

  bool _isImporting = false;

  @override
  void initState() {
    super.initState();

    _selected = List<bool>.filled(
      widget.archive.resources.length,
      true,
    );
  }

  Future<void> _import() async {
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

    setState(() {
      _isImporting = true;
    });

    try {
      final archive = ShareArchive(
        manifest: widget.archive.manifest,
        resources: resources,
      );

      final result = await ref
          .read(
        shareImportControllerProvider.notifier,
      )
          .importArchive(
        archive,
      );

      if (!mounted) {
        return;
      }

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errors.join('\n'),
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${resources.length} item(s).',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
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
                onPressed:
                _isImporting
                    ? null
                    : _import,
                child: Text(
                  _isImporting
                      ? 'Importing...'
                      : 'Import Selected',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}