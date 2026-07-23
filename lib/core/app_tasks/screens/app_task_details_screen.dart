import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_task_status.dart';
import '../providers/app_task_provider.dart';

class AppTaskDetailsScreen extends ConsumerWidget {
  const AppTaskDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(appTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Tasks'),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          'No background tasks.',
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = tasks.reversed.elementAt(index);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _StatusIcon(task.status),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.message,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon(this.status);

  final AppTaskStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppTaskStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
        );

      case AppTaskStatus.failed:
        return const Icon(
          Icons.error,
          color: Colors.red,
        );

      default:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
    }
  }
}