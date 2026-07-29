import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Create/Edit Grading Structure screen
/// (`lib/features/grades/screens/grading/create_grading_structure_screen.dart`).
/// Anchors live in `lib/features/grades/widgets/grading/structures/grading_structure_card.dart`
/// (the "Add Component" button, always present) and
/// `lib/features/grades/widgets/grading/component/grading_component_card.dart`
/// (the first component's header and "Add Subcomponent" button). The
/// latter two only exist once at least one component does — [setPreviewMode]
/// makes the editor show a non-interactive example in their place on a
/// brand-new, empty structure, so the tutorial isn't the one place in the
/// app that assumes the user already did the thing it's explaining.
List<HelpTopic> gradingStructureHelpTopics({
  required void Function(bool) setPreviewMode,
}) {
  return [
    HelpTopic(
      id: 'what-is-a-component',
      title: 'What is a Component?',
      onDismiss: () => setPreviewMode(false),
      steps: [
        HelpStep(
          description:
              'A Component is one graded category in this course — like '
              '"Assignments," "Midterms," or "Final Exam." Each one has a '
              'weight (%) that says how much it counts toward your final '
              'grade.',
          anchorId: 'add-component-button',
        ),
        HelpStep(
          description:
              'Once added, you can rename it and set its weight here.',
          anchorId: 'component-header',
          beforeShow: () async => setPreviewMode(true),
        ),
      ],
    ),
    HelpTopic(
      id: 'what-is-a-subcomponent',
      title: 'What is a Subcomponent?',
      onDismiss: () => setPreviewMode(false),
      steps: [
        HelpStep(
          description:
              'A Subcomponent breaks a Component into smaller pieces — for '
              'example, splitting "Exams" into "Midterm" and "Final." '
              'Their weights apply within that Component\'s own share, not '
              'the whole course.',
          anchorId: 'add-subcomponent-button',
          beforeShow: () async => setPreviewMode(true),
        ),
      ],
    ),
  ];
}
