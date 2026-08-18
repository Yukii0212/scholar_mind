import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/countdown_item.dart';
import '../providers/countdown_provider.dart';

class CountdownActions {
  const CountdownActions._();

  /// Returns whether the countdown was actually deleted (`false` if the
  /// user cancelled the confirmation), so callers that need to react --
  /// e.g. popping an edit screen for the item just deleted -- can do so
  /// without guessing.
  static Future<bool> delete(
      BuildContext context,
      WidgetRef ref,
      String userId,
      CountdownItem item,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete countdown?'),
        content: Text(
          'This will remove "${item.title}" permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }

    await ref.read(countdownRepositoryProvider).deleteCountdown(
      userId: userId,
      countdownId: item.id,
    );

    return true;
  }
}