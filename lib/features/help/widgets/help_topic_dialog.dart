import 'package:flutter/material.dart';

/// Plain explanation dialog used for topics with no on-screen anchor, or
/// whose anchor isn't currently mounted (e.g. a conditionally-hidden
/// widget, or a different page of a swipe carousel).
Future<void> showHelpTopicDialog(
  BuildContext context, {
  required String title,
  required String description,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}
