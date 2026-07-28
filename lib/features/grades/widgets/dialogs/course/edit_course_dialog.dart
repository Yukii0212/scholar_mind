import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/course_model.dart';
import '../../../providers/course/course_provider.dart';

class EditCourseDialog extends ConsumerStatefulWidget {
  const EditCourseDialog({
    super.key,
    required this.course,
    this.deleteOnCancel = false,
    this.title = 'Edit Course',
    this.isImport = false,
  });

  final CourseModel course;
  final bool deleteOnCancel;
  final String title;
  final bool isImport;

  @override
  ConsumerState<EditCourseDialog> createState() =>
      _EditCourseDialogState();
}

class _EditCourseDialogState
    extends ConsumerState<EditCourseDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetScoreController;

  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.course.name,
    );

    _targetScoreController = TextEditingController(
      text: widget.course.targetScore
          ?.toStringAsFixed(0) ??
          '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetScoreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updated = widget.course.copyWith(
      name: _nameController.text.trim(),
      targetScore:
      _targetScoreController
          .text
          .trim()
          .isEmpty
          ? null
          : double.tryParse(
        _targetScoreController.text
            .trim(),
      ),
    );

    await ref
        .read(courseRepositoryProvider)
        .updateCourse(updated);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a course name.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _targetScoreController,
                  decoration: const InputDecoration(
                    labelText:
                    'Target Score (Optional)',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed:
                  _isSaving ? null : _save,
                  child: const Text('Save'),
                ),

                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                    if (widget.deleteOnCancel) {
                      await ref
                          .read(courseRepositoryProvider)
                          .deleteCourse(
                        widget.course.id,
                      );
                    }

                    if (!mounted) {
                      return;
                    }

                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}