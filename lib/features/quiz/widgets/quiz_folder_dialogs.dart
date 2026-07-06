import 'package:flutter/material.dart';

class CreateQuizFolderDialog
    extends StatefulWidget {
  const CreateQuizFolderDialog({
    super.key,
  });

  @override
  State<CreateQuizFolderDialog>
  createState() =>
      _CreateQuizFolderDialogState();
}

class _CreateQuizFolderDialogState
    extends State<CreateQuizFolderDialog> {
  final _controller =
  TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'New folder',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        textInputAction:
        TextInputAction.done,
        decoration:
        const InputDecoration(
          labelText: 'Folder name',
          hintText:
          'Networking',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child:
          const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child:
          const Text('Create'),
        ),
      ],
    );
  }

  void _submit() {
    final name =
    _controller.text.trim();

    if (name.isNotEmpty) {
      Navigator.pop(
        context,
        name,
      );
    }
  }
}