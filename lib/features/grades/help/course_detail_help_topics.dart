import 'package:flutter/material.dart';

import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for `CourseAnalyticsScreen`
/// (`lib/features/grades/screens/course/course_analytics_screen.dart`),
/// a 3-page swipe carousel: Overview (page 0), Targets (page 1), and
/// Predictions (page 2). [revealAnalyticsItem] switches to a given page
/// before each step tries to spotlight anything in it.
///
/// The first topic below (`page-overview`) has no anchors — it's a plain
/// walk-through of each page with nothing spotlit, meant to be seen
/// before any of the detail topics that follow. A first-time user who
/// gets dropped straight into "here's this one field" with no sense of
/// the page around it has nowhere to hang that information — showing the
/// whole page first gives the later, narrower steps something to anchor
/// to conceptually, not just visually.
List<HelpTopic> courseDetailHelpTopics({
  required Future<void> Function(int page) revealAnalyticsItem,
  required void Function(bool) setProjectedScorePreview,
  required void Function(bool) setRequiredScorePreview,
}) {
  HelpStep step({
    required String description,
    required String anchorId,
    int page = 0,
    List<HelpColorLegendEntry>? colorLegend,
    double scrimOpacity = HelpStep.heavyScrim,
    bool showHighlightRing = true,
  }) {
    return HelpStep(
      description: description,
      anchorId: anchorId,
      colorLegend: colorLegend,
      scrimOpacity: scrimOpacity,
      showHighlightRing: showHighlightRing,
      beforeShow: () => revealAnalyticsItem(page),
    );
  }

  // Lightly dimmed rather than fully bright — the point of these steps is
  // to let the real page be seen, but a fully undimmed background leaves
  // nothing to keep visual weight on the tutorial bubble itself.
  HelpStep pageIntro({
    required String description,
    required int page,
  }) {
    return HelpStep(
      description: description,
      beforeShow: () => revealAnalyticsItem(page),
      scrimOpacity: HelpStep.lightScrim,
    );
  }

  return [
    HelpTopic(
      id: 'page-overview',
      title: "What's on this page?",
      steps: [
        const HelpStep(
          description:
              "This page shows how you're doing in this course. Let's "
              'take a quick look at it.',
        ),
        pageIntro(
          page: 0,
          description:
              'This page has three tabs, swipe between them or use the '
              'buttons above each card. This one is Overview — it shows '
              'how you\'re doing in this course right now.',
        ),
        pageIntro(
          page: 1,
          description:
              'This is Targets. It tells you the exact score you need on '
              'your next assessment to hit a goal, like your Target Score '
              'or your Passing Score.',
        ),
        pageIntro(
          page: 2,
          description:
              'This is Predictions. It looks ahead at how your final '
              'grade could turn out based on the scores you\'ve entered '
              'so far.',
        ),
      ],
    ),
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
              'This card tells you if you\'re on track to reach your '
              'goal. Look at the color of its border:',
          anchorId: 'progress-towards-goal',
          scrimOpacity: HelpStep.lightScrim,
          showHighlightRing: false,
          colorLegend: const [
            HelpColorLegendEntry(
              color: Colors.green,
              label: 'You\'re on track.',
            ),
            HelpColorLegendEntry(
              color: Colors.amber,
              label: 'Still possible, but you\'ll need to improve.',
            ),
            HelpColorLegendEntry(
              color: Colors.red,
              label: 'No longer possible.',
            ),
          ],
        ),
      ],
    ),
    HelpTopic(
      id: 'target-score-field',
      title: 'How do I set a Target Score?',
      steps: [
        step(
          description:
              'Type the percentage you want to reach in this course. If '
              'you don\'t set one, we\'ll track your progress toward your '
              'Passing Score instead (the minimum score you need to pass).',
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
      onDismiss: () => setRequiredScorePreview(false),
      steps: [
        HelpStep(
          description:
              'Shows exactly what you need on your last remaining '
              'assessment to hit each target.',
          anchorId: 'required-score-calculator',
          beforeShow: () async {
            await revealAnalyticsItem(1);
            setRequiredScorePreview(true);
          },
        ),
      ],
    ),
  ];
}
