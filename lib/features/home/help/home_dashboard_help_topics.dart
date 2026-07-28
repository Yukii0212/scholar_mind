import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the `/home` dashboard, wired through the shared shell
/// AppBar. Anchors live in `lib/features/home/widgets/grades/semester_panel.dart`.
const homeDashboardHelpTopics = <HelpTopic>[
  HelpTopic(
    id: 'course-standing-chip',
    title: 'What do "On Track / At Risk / Needs Work" mean?',
    steps: [
      HelpStep(
        description:
            'A quick-glance label per course: projected to hit your goal (or '
            'pass, if you haven\'t set a personal target), still mathematically '
            'able to, or falling short even in the best case.',
        anchorId: 'course-standing-chip',
      ),
    ],
  ),
];
