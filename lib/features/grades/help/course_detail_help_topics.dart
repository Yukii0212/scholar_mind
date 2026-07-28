import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Course Detail screen
/// (`lib/features/grades/screens/course/course_detail_screen.dart`),
/// wired via that screen's own local AppBar. Anchors live in
/// `lib/features/grades/widgets/course/course_standing_card.dart` (swipe
/// page 0, "Overview") and `course_targets_card.dart` (swipe page 1,
/// "Targets").
///
/// Every anchor below lives on the Analytics tab — `CurrentStandingCard`
/// and `CourseTargetsCard` aren't even built while the Assessment tab is
/// selected, a hard `if`/`else` in `course_detail_body.dart`, not a
/// lazily-built carousel page — so every step switches to the right tab
/// and swipe page via [showAnalyticsTab] before trying to spotlight
/// anything.
List<HelpTopic> courseDetailHelpTopics({
  required void Function(int page) showAnalyticsTab,
}) {
  HelpStep step({
    required String description,
    required String anchorId,
    int page = 0,
  }) {
    return HelpStep(
      description: description,
      anchorId: anchorId,
      beforeShow: () => showAnalyticsTab(page),
    );
  }

  return [
    HelpTopic(
      id: 'guaranteed-score',
      title: 'What does "Current Score" mean?',
      steps: [
        step(
          description:
              'The percentage you\'ve already locked in from graded work — '
              'it can only go up as more results come in.',
          anchorId: 'guaranteed-score',
        ),
      ],
    ),
    HelpTopic(
      id: 'projected-score',
      title: 'What does "Projected Score" mean?',
      steps: [
        step(
          description:
              'Your expected final score once you\'ve entered "Expected" '
              'values for ungraded work — a forecast, not a guarantee.',
          anchorId: 'projected-score',
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
              'everything remaining — your ceiling.',
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
              'Compares your current/projected score against your Target '
              'Score (or your Passing Score, if you haven\'t set one) and '
              'tells you whether you\'re on track, at risk, or already '
              'there.',
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
              'Passing Score instead.',
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
              'An optional personal floor — the lowest score you\'d '
              'tolerate before feeling you need to step in.',
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
              'The minimum percentage required to pass this course. '
              'Defaults to 50%, and you can change it — used to judge your '
              'standing whenever you haven\'t set a Target Score.',
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
              'Once only one assessment is left ungraded or unestimated, '
              'this shows exactly what you need to score on it to hit each '
              'target.',
          anchorId: 'required-score-calculator',
          page: 1,
        ),
      ],
    ),
  ];
}
