import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/course_model.dart';
import '../../../providers/course/course_provider.dart';

class CreateCourseDialog extends ConsumerStatefulWidget {
  const CreateCourseDialog({
    super.key,
    required this.semesterId,
  });

  final String semesterId;

  @override
  ConsumerState<CreateCourseDialog> createState() =>
      _CreateCourseDialogState();
}

class _CreateCourseDialogState
    extends ConsumerState<CreateCourseDialog> {
  final _nameController = TextEditingController();
  final _targetScoreController =
  TextEditingController();
  final _passingScoreController =
  TextEditingController(text: '50');

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetScoreController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();

    final course = CourseModel(
      id: const Uuid().v4(),
      // Overwritten by CourseRepository.createCourse before it's persisted.
      ownerId: '',
      semesterId: widget.semesterId,
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
      passingScore:
      double.tryParse(
        _passingScoreController.text.trim(),
      ) ??
          50,
      createdAt: now,
      updatedAt: now,
    );

    await ref
        .read(courseRepositoryProvider)
        .createCourse(course);

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      course,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create Course',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization:
                  TextCapitalization.words,
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
                    labelText: 'Target Score (Optional)',
                    hintText: 'Example: 80',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    errorMaxLines: 2,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }

                    final score = double.tryParse(value.trim());

                    if (score == null) {
                      return 'Please enter a valid number.';
                    }

                    if (score < 0 || score > 100) {
                      return 'Target score must be between 0% and 100%.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passingScoreController,
                  decoration: const InputDecoration(
                    labelText: 'Passing Score',
                    hintText: 'Example: 50',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    errorMaxLines: 2,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a passing score.';
                    }

                    final score = double.tryParse(value.trim());

                    if (score == null) {
                      return 'Please enter a valid number.';
                    }

                    if (score < 0 || score > 100) {
                      return 'Passing score must be between 0% and 100%.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : _createCourse,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Create',
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () =>
                        Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}