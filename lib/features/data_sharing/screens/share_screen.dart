import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_tasks/domain/app_task.dart';
import '../../../core/app_tasks/domain/app_task_status.dart';
import '../../../core/app_tasks/domain/app_task_type.dart';
import '../../../core/app_tasks/providers/app_task_provider.dart';
import '../../../core/app_tasks/services/app_task_controller.dart';
import '../domain/models/share/share_expiry.dart';
import '../domain/models/share/share_result.dart';
import '../providers/export/export_controller.dart';
import '../providers/export/export_statistics_provider.dart';
import '../services/export_time_estimate.dart';
import 'my_shared_links_screen.dart';
import '../widgets/screen/share/share_link_view.dart';
import '../widgets/screen/share/share_qr_view.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({
    super.key,
  });

  @override
  ConsumerState<ShareScreen> createState() =>
      _ShareScreenState();
}

class _ShareScreenState
    extends ConsumerState<ShareScreen> {
  var _selectedIndex = 1;

  ShareResult? _share;

  String? _activeTaskId;

  ShareExpiry _expiry = ShareExpiry.oneDay;

  void _startGenerate() {
    final shareId = const Uuid().v4();
    final taskId = 'export_$shareId';

    setState(() {
      _activeTaskId = taskId;
    });

    unawaited(
      ref.read(appTaskControllerProvider).run<ShareResult?>(
        id: taskId,
        type: AppTaskType.export,
        title: 'Generating share link',
        task: (progress) => ref
            .read(exportControllerProvider.notifier)
            .generateShare(
          expiry: _expiry,
          shareId: shareId,
          onProgress: progress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<AppTask>>(appTaskProvider, (previous, next) {
      final activeId = _activeTaskId;

      if (activeId == null) {
        return;
      }

      final task = ref.read(appTaskProvider.notifier).taskById(activeId);

      if (task == null) {
        return;
      }

      if (task.status == AppTaskStatus.completed) {
        setState(() {
          _share = task.payload as ShareResult?;
          _selectedIndex = 1;
          _activeTaskId = null;
        });
      } else if (task.status == AppTaskStatus.failed) {
        final error = task.error;

        setState(() {
          _activeTaskId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate share link: $error'),
          ),
        );
      }
    });

    final tasks = ref.watch(appTaskProvider);

    AppTask? activeTask;

    if (_activeTaskId != null) {
      for (final task in tasks) {
        if (task.id == _activeTaskId) {
          activeTask = task;
          break;
        }
      }
    }

    final generating = activeTask != null;
    final hasShare = _share != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MySharedLinksScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
            tooltip: 'My shared links',
          ),
          if (hasShare)
            TextButton.icon(
              onPressed: generating ? null : _startGenerate,
              icon: const Icon(Icons.refresh),
              label: const Text('New Link'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share your study materials',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Anyone with ScholarMind can import these materials.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              if (!hasShare) ...[
                const SizedBox(height: 24),

                DropdownButtonFormField<ShareExpiry>(
                  value: _expiry,
                  decoration: const InputDecoration(
                    labelText: 'Link Expiry',
                    border: OutlineInputBorder(),
                  ),
                  items: ShareExpiry.values
                      .map(
                        (expiry) => DropdownMenuItem(
                      value: expiry,
                      child: Text(expiry.label),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _expiry = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: generating ? null : _startGenerate,
                  icon: generating
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.link),
                  label: const Text(
                    'Generate Link',
                  ),
                ),

                const SizedBox(height: 8),

                if (generating)
                  Text(
                    activeTask.message.isNotEmpty
                        ? activeTask.message
                        : 'Starting export...',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  Consumer(
                    builder: (context, ref, _) {
                      final stats = ref.watch(exportStatisticsProvider);

                      return stats.when(
                        data: (value) => value.hasSelection
                            ? Text(
                          'Estimated time: '
                              '${estimateExportDuration(value)}',
                          style:
                          Theme.of(context).textTheme.bodySmall,
                        )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),

                Text(
                  'You can leave this screen while your link '
                  'is generating — it keeps working in the '
                  'background and you can check progress or '
                  'find it later from the history icon above.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      icon: Icon(Icons.qr_code),
                      label: Text('QR Code'),
                    ),
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.link),
                      label: Text('Link'),
                    ),
                  ],
                  selected: {_selectedIndex},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedIndex = selection.first;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _selectedIndex == 0
                      ? ShareQrView(
                    share: _share,
                  )
                      : ShareLinkView(
                    share: _share,
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