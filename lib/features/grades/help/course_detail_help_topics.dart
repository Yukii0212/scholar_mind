import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Course Detail screen
/// (`lib/features/grades/screens/course/course_detail_screen.dart`).
///
/// Every anchor below lives inside `CurrentStandingCard` (swipe page 0,
/// "Overview") or `CourseTargetsCard` (swipe page 1, "Targets"), on the
/// Analytics tab (`lib/core/widgets/swipe_cards/`). [revealAnalyticsItem]
/// switches to that tab and page before each step tries to spotlight
/// anything.
List<HelpTopic> courseDetailHelpTopics({
  required Future<void> Function(int page) revealAnalyticsItem,
  required void Function(bool) setProjectedScorePreview,
}) {
  HelpStep step({
    required String description,
    required String anchorId,
    int page = 0,
  }) {
    return HelpStep(
      description: description,
      anchorId: anchorId,
      beforeShow: () => revealAnalyticsItem(page),
    );
  }

  return [
    HelpTopic(
      id: 'guaranteed-score',
      title: 'What does "Current Score" mean?',
      steps: [
        step(
          description:
              'What you\'ve earned so far from graded assessments — it '
              'only goes up as more of your work gets scored.',
          anchorId: 'guaranteed-score',
        ),
      ],
    ),
    HelpTopic(
      id: 'projected-score',
      title: 'What does "Projected Score" mean?',
      onDismiss: () => setProjectedScorePreview(false),
      steps: [
        HelpStep(
          description:
              'Your expected final score once you\'ve entered "Expected" '
              'values for ungraded work — a forecast, not a guarantee.',
          anchorId: 'projected-score',
          beforeShow: () async {
            await revealAnalyticsItem(0);
            setProjectedScorePreview(true);
          },
        ),
      ],
    ),
    HelpTopic(
      id: 'maximum-achievable',
      title: 'What does "Maximum Achievable" mean?',
      steps: [
        step(
          description:
              'The best possible final score if you scored 100% on '
              'everything remaining.',
          anchorId: 'maximum-achievable',
        ),
      ],
    ),
    HelpTopic(
      id: 'progress-towards-goal',
      title: 'What does the "Progress Towards Goal" card tell me?',
      steps: [
        step(
          description:
              'Border color tells you where you stand at a glance: green '
              'means on track, amber means still possible but you\'ll need '
              'to step up, red means no longer achievable.',
          anchorId: 'progress-towards-goal',
        ),
      ],
    ),
    HelpTopic(
      id: 'target-score-field',
      title: 'How do I set a Target Score?',
      steps: [
        step(
          description:
              'Type the final percentage you\'re personally aiming for. '
              'Leave it blank and we\'ll track your progress against your '
              'Passing Score — the minimum needed to pass — instead.',
          anchorId: 'target-score-field',
        ),
      ],
    ),
    HelpTopic(
      id: 'minimum-acceptable-field',
      title: 'What is "Minimum Acceptable"?',
      steps: [
        step(
          description:
              'The lowest score you\'d personally accept for this course.',
          anchorId: 'minimum-acceptable-field',
        ),
      ],
    ),
    HelpTopic(
      id: 'passing-score-field',
      title: 'What is "Passing Score"?',
      steps: [
        step(
          description:
              'The minimum percentage required to pass this course. You '
              'can change it.',
          anchorId: 'passing-score-field',
        ),
      ],
    ),
    HelpTopic(
      id: 'required-score-calculator',
      title: 'What does the "Required Score Calculator" show?',
      steps: [
        step(
          description:
              'Shows exactly what you need on your last remaining '
              'assessment to hit each target.',
          anchorId: 'required-score-calculator',
          page: 1,
        ),
      ],
    ),
  ];
}
