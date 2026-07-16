import 'package:flutter/material.dart';

class GradingComponentDialog
    extends StatefulWidget {
  const GradingComponentDialog({
    super.key,
    this.title = 'Create Component',
    this.initialName = '',
  });

  final String title;
  final String initialName;

  @override
  State<GradingComponentDialog> createState() =>
      _GradingComponentDialogState();
}

class _GradingComponentDialogState
    extends State<GradingComponentDialog> {
  late final TextEditingController
  _nameController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 450,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              autofocus: true,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Component Name',
                      border:
                      OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Please enter a component name.';
                      }

                      return null;
                    },
                    onFieldSubmitted:
                        (_) => _create(),
                  ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      child:
                      const Text(
                        'Cancel',
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: _create,
                      child:
                      const Text(
                        'Create',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}