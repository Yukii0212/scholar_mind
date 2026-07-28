import '../../help/domain/help_topic.dart';

/// Help topics for the Course Detail screen
/// (`lib/features/grades/screens/course/course_detail_screen.dart`),
/// wired via that screen's own local AppBar. Anchors live in
/// `lib/features/grades/widgets/course/course_standing_card.dart` and
/// `lib/features/grades/widgets/course/course_targets_card.dart`.
///
/// `CurrentStandingCard`, `CourseTargetsCard`, and `CoursePredictionCard`
/// are separate pages of a swipe carousel (`course_detail_body.dart`), so
/// a topic anchored on a card the user isn't currently viewing falls back
/// to a plain explanation dialog instead of a spotlight.
const courseDetailHelpTopics = <HelpTopic>[
  HelpTopic(
    id: 'guaranteed-score',
    title: 'What does "Current Score" mean?',
    description:
        'The percentage you\'ve already locked in from graded work — it '
        'can only go up as more results come in.',
    anchorId: 'guaranteed-score',
  ),
  HelpTopic(
    id: 'projected-score',
    title: 'What does "Projected Score" mean?',
    description:
        'Your expected final score once you\'ve entered "Expected" values '
        'for ungraded work — a forecast, not a guarantee.',
    anchorId: 'projected-score',
  ),
  HelpTopic(
    id: 'maximum-achievable',
    title: 'What does "Maximum Achievable" mean?',
    description:
        'The best possible final score if you scored 100% on everything '
        'remaining — your ceiling.',
    anchorId: 'maximum-achievable',
  ),
  HelpTopic(
    id: 'progress-towards-goal',
    title: 'What does the "Progress Towards Goal" card tell me?',
    description:
        'Compares your current/projected score against your Target Score '
        '(or your Passing Score, if you haven\'t set one) and tells you '
        'whether you\'re on track, at risk, or already there.',
    anchorId: 'progress-towards-goal',
  ),
  HelpTopic(
    id: 'target-score-field',
    title: 'How do I set a Target Score?',
    description:
        'Type the final percentage you\'re personally aiming for. Leave '
        'it blank and we\'ll track your progress against your Passing '
        'Score instead.',
    anchorId: 'target-score-field',
  ),
  HelpTopic(
    id: 'minimum-acceptable-field',
    title: 'What is "Minimum Acceptable"?',
    description:
        'An optional personal floor — the lowest score you\'d tolerate '
        'before feeling you need to step in.',
    anchorId: 'minimum-acceptable-field',
  ),
  HelpTopic(
    id: 'passing-score-field',
    title: 'What is "Passing Score"?',
    description:
        'The minimum percentage required to pass this course. Defaults '
        'to 50%, and you can change it — used to judge your standing '
        'whenever you haven\'t set a Target Score.',
    anchorId: 'passing-score-field',
  ),
  HelpTopic(
    id: 'required-score-calculator',
    title: 'What does the "Required Score Calculator" show?',
    description:
        'Once only one assessment is left ungraded or unestimated, this '
        'shows exactly what you need to score on it to hit each target.',
    anchorId: 'required-score-calculator',
  ),
];
