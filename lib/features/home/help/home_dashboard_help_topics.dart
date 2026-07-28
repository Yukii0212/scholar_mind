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
            '"On Track": your current or projected score already meets '
            'your goal — your Target Score if you set one, otherwise your '
            'Passing Score.',
        anchorId: 'course-standing-chip',
      ),
      HelpStep(
        description:
            '"At Risk": even scoring 100% on everything left wouldn\'t be '
            'enough to reach your goal anymore — mathematically out of '
            'reach.',
        anchorId: 'course-standing-chip',
      ),
      HelpStep(
        description:
            '"Needs Work": every remaining assessment already has a score '
            'or an estimate, and your projected score still falls short of '
            'your goal. Still achievable, just not there yet.',
        anchorId: 'course-standing-chip',
      ),
      HelpStep(
        description:
            '"No Data Yet": you haven\'t entered any scores for this '
            'course, so there\'s nothing to project a standing from.',
        anchorId: 'course-standing-chip',
      ),
    ],
  ),
];
