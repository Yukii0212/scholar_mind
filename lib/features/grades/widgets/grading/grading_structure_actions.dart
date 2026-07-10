import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grading/grading_structure_draft_provider.dart';
import '../../providers/grading/grading_structure_controller.dart';
import '../../services/grading/grading_structure_validator.dart';

class GradingStructureActions
    extends ConsumerWidget {
  const GradingStructureActions({
    super.key,
    required this.courseId,
    required this.isEditing,
  });

  final String courseId;
  final bool isEditing;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async {
            final draft = ref.read(
              gradingStructureDraftProvider,
            );

            final result =
            GradingStructureValidator
                .validate(draft);

            if (!result.isValid) {
              await showDialog(
                context: context,
                builder: (_) =>
                    _ValidationDialog(
                      errors: result.errors,
                    ),
              );

              return;
            }

            await ref
                .read(
              gradingStructureControllerProvider,
            )
                .saveCourse(courseId);

            if (!context.mounted) {
              return;
            }

            Navigator.pop(context);
          },
          child: Text(
            isEditing
                ? 'Save Changes'
                : 'Create Grading Structure',
          ),
        ),

        const SizedBox(height: 8),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
          ),
        ),
      ],
    );
  }
}

class _ValidationDialog
    extends StatelessWidget {
  const _ValidationDialog({
    required this.errors,
  });

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Invalid Grading Structure',
      ),
      content: Column(
        mainAxisSize:
        MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: errors
            .map(
              (error) => Padding(
            padding:
            const EdgeInsets.only(
              bottom: 8,
            ),
            child: Text(
              '• $error',
            ),
          ),
        )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Go Back',
          ),
        ),
      ],
    );
  }
}