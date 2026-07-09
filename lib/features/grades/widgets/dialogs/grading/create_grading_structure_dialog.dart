import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/grading/grading_structure_controller.dart';
import '../../grading/grading_structure_editor.dart';

class CreateGradingStructureDialog
    extends ConsumerStatefulWidget {
  const CreateGradingStructureDialog({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  ConsumerState<CreateGradingStructureDialog>
  createState() =>
      _CreateGradingStructureDialogState();
}

class _CreateGradingStructureDialogState
    extends ConsumerState<
        CreateGradingStructureDialog> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    await ref
        .read(
      gradingStructureControllerProvider,
    )
        .saveCourse(widget.courseId);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  void _cancel() {
    ref
        .read(
      gradingStructureControllerProvider,
    )
        .discard();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Create Grading Structure',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 24),

              const Expanded(
                child:
                GradingStructureEditor(),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                    _isSaving
                        ? null
                        : _cancel,
                    child:
                    const Text('Cancel'),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}