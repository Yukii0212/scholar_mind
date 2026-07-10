import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/grading/grading_structure_controller.dart';
import 'grading_structure_actions.dart';
import 'grading_structure_card.dart';

class GradingStructureEditor extends ConsumerStatefulWidget {
  const GradingStructureEditor({
    super.key,
    required this.courseId,
    required this.isEditing,
  });

  final String courseId;
  final bool isEditing;

  @override
  ConsumerState<GradingStructureEditor> createState() =>
      _GradingStructureEditorState();
}

class _GradingStructureEditorState
    extends ConsumerState<GradingStructureEditor> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final controller = ref.read(
        gradingStructureControllerProvider,
      );

      if (widget.isEditing) {
        await controller.loadCourse(
          widget.courseId,
        );
      } else {
        controller.discard();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        const GradingStructureCard(),

        const SizedBox(height: 24),

        GradingStructureActions(
          courseId: widget.courseId,
          isEditing: widget.isEditing,
        ),
      ],
    );
  }
}