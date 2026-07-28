import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';
import 'standing_chip_preview_provider.dart';

/// Help topics for the `/home` dashboard, wired through the shared shell
/// AppBar. Anchors live in `lib/features/home/widgets/grades/semester_panel.dart`.
///
/// The single topic below walks through all four standing states, but only
/// one is ever true for the course it's anchored on — [setStandingPreview]
/// lets each step temporarily swap the chip to the state it's currently
/// explaining, so what's highlighted actually matches what's being said.
List<HelpTopic> homeDashboardHelpTopics({
  required void Function(StandingPreview?) setStandingPreview,
}) {
  HelpStep step({
    required String description,
    required StandingPreview preview,
  }) {
    return HelpStep(
      description: description,
      anchorId: 'course-standing-chip',
      beforeShow: () async => setStandingPreview(preview),
    );
  }

  return [
    HelpTopic(
      id: 'course-standing-chip',
      title: 'What do "On Track / Not Achievable / Needs Work" mean?',
      onDismiss: () => setStandingPreview(null),
      steps: [
        step(
          description:
              '"On Track": your current or projected score already meets '
              'your goal — your Target Score if you set one, otherwise your '
              'Passing Score.',
          preview: StandingPreview.onTrack,
        ),
        step(
          description:
              '"Not Achievable": even scoring 100% on everything left '
              'wouldn\'t be enough to reach your goal anymore — '
              'mathematically out of reach.',
          preview: StandingPreview.notAchievable,
        ),
        step(
          description:
              '"Needs Work": every remaining assessment already has a '
              'score or an estimate, and your projected score still falls '
              'short of your goal. Still achievable, just not there yet.',
          preview: StandingPreview.needsWork,
        ),
        step(
          description:
              '"No Data Yet": you haven\'t entered any scores for this '
              'course, so there\'s nothing to project a standing from.',
          preview: StandingPreview.noData,
        ),
      ],
    ),
  ];
}
