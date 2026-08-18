import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Study Streak screen
/// (`lib/features/study_streak/screens/study_streak_screen.dart`).
/// Anchors live in that same file: the streak count and its stat tiles in
/// `_StreakHero`, and the "Activity Calendar" header in `_ActivityCalendar`.
/// All three are part of the screen's always-present chrome, so they show
/// up the same way for a brand-new user with no recorded activity yet.
List<HelpTopic> studyStreakHelpTopics() {
  return [
    const HelpTopic(
      id: 'streak-basics',
      title: 'How Your Streak Works',
      steps: [
        HelpStep(
          description:
              'This is your current streak — the number of days in a row '
              "you've opened ScholarMind. It ticks up automatically the "
              "first time you visit the home dashboard each day, and "
              "resets to zero if you miss one.",
          anchorId: 'streak-hero-count',
        ),
        HelpStep(
          description:
              'Longest is the best streak you\'ve ever had, Total Days is '
              'every day you\'ve shown up in total, and Badges counts how '
              'many streak achievements you\'ve unlocked.',
          anchorId: 'streak-hero-stats',
        ),
      ],
    ),
    const HelpTopic(
      id: 'activity-calendar',
      title: 'Activity Calendar',
      steps: [
        HelpStep(
          description:
              'Marked days here show when you opened ScholarMind — the '
              'same activity that builds your streak above. Use the '
              'arrows (or swipe) to browse earlier months.',
          anchorId: 'activity-calendar-header',
        ),
      ],
    ),
  ];
}
