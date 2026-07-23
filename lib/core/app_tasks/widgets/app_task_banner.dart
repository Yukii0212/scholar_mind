import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_task_status.dart';
import '../providers/app_task_provider.dart';
import '../screens/app_task_details_screen.dart';
import '../services/app_task_controller.dart';

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

    return Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          0,
        ),
        child: Dismissible(
            key: ValueKey(task.id),
            direction:
            task.status ==
                AppTaskStatus.completed ||
                task.status ==
                    AppTaskStatus.failed
                ? DismissDirection.horizontal
                : DismissDirection.none,
            onDismissed: (_) {
              ref
                  .read(
                appTaskProvider.notifier,
              )
                  .remove(task.id);
            },
            child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                    behavior:
                    HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  final controller =
                  ref.read(
                    appTaskControllerProvider,
                  );

                  final velocity =
                      details.primaryVelocity ?? 0;

                  if (velocity < -150) {
                    controller.collapse(task.id);
                  } else if (velocity > 150) {
                    controller.expand(task.id);
                  }
                },
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                        const AppTaskDetailsScreen(),
                      ),
                    );
                  },
                  child: AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration:
                    const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: task.isCollapsed
                          ? Row(
                        children: [
                          switch (task.status) {
                            AppTaskStatus.completed =>
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            AppTaskStatus.failed =>
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                            _ =>
                            const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          },
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                                if (task.message.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                    ),
                                    child: ConstrainedBox(
                                      constraints:
                                      const BoxConstraints(
                                        maxWidth: 120,
                                      ),
                                      child: Text(
                                        task.message
                                            .split('\n')
                                            .first,
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Icon(
                            Icons.expand_more,
                          ),
                        ],
                      )
                          : Row(
                        children: [
              switch (task.status) {
                AppTaskStatus.completed => const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                AppTaskStatus.failed => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                _ => const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              },
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

                    if (task.status ==
                        AppTaskStatus.completed)
                      Text(
                        'Completed',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Colors.green,
                        ),
                      ),

                    if (task.status ==
                        AppTaskStatus.failed)
                      Text(
                        'Failed',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),

              if (task.status ==
                  AppTaskStatus.completed ||
                  task.status ==
                      AppTaskStatus.failed)
                TextButton(
                  onPressed: () {
                    ref
                        .read(
                      appTaskProvider.notifier,
                    )
                        .remove(task.id);
                  },
                  child: const Text(
                    'Dismiss',
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                ),
            ],
          ),
        ),
            ),
        )
            )
        )
        )
    );
  }
}