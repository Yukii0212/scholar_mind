import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_task_status.dart';
import '../providers/app_task_provider.dart';
import '../screens/app_task_details_screen.dart';

class AppTaskBanner extends ConsumerWidget {
  const AppTaskBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appTaskProvider);

    final task =
        ref.read(appTaskProvider.notifier).currentTask;

    if (task == null) {
      return const SizedBox.shrink();
    }

    if (task.status == AppTaskStatus.completed ||
        task.status == AppTaskStatus.failed) {
      return const SizedBox.shrink();
    }

    return Material(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
              const AppTaskDetailsScreen(),
            ),
          );
        },
          child: Row(
            children: [
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall,
                    ),
                    if (task.message.isNotEmpty)
                      Text(
                        task.message,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
  }
}