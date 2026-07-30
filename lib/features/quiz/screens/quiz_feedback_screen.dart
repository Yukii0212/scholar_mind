import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_feedback_entry.dart';
import '../providers/quiz_feedback_provider.dart';

/// Lets the user review and manage every question they've marked "Not
/// Important" from a completed quiz -- see quiz_result_screen.dart for
/// where entries are added, and quiz_feedback_provider.dart /
/// quiz_repository.dart for how a recent slice of this feeds back into
/// future generation prompts.
class QuizFeedbackScreen extends ConsumerWidget {
  const QuizFeedbackScreen({super.key});

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Flagged Questions?'),
          content: const Text(
            'This removes everything you\'ve marked as not important. '
            'Future quizzes will no longer avoid these topics.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(quizFeedbackActionControllerProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(quizFeedbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flagged Questions'),
        actions: [
          feedbackAsync.maybeWhen(
            data: (entries) => entries.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Clear All',
                    onPressed: () => _clearAll(context, ref),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: feedbackAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Could not load flagged questions: $error'),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No flagged questions yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mark a question "Not Important" from any quiz\'s '
                      'results to steer future quizzes away from similar '
                      'ones.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];

              return _FeedbackCard(
                entry: entry,
                onDelete: () => ref
                    .read(quizFeedbackActionControllerProvider.notifier)
                    .deleteFeedback(entry.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.entry,
    required this.onDelete,
  });

  final QuizFeedbackEntry entry;
  final VoidCallback onDelete;

  String get _typeLabel => switch (entry.questionType) {
        'multiple_choice' => 'Multiple Choice',
        'true_false' => 'True / False',
        'open_ended' => 'Open Ended',
        _ => entry.questionType,
      };

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.questionText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Remove',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(_typeLabel),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(
                    '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (entry.reason != null && entry.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${entry.reason}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.outline,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
