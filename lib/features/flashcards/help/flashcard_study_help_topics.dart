import 'package:flutter/material.dart';

import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the Flashcard Study Session screen
/// (`lib/features/flashcards/screens/flashcard_study_session_screen.dart`).
/// The `study-swipe-card` anchor lives on the [StudySwipeCards] widget
/// there, which is on screen for the whole active study session, so it's
/// safe to anchor on for a brand-new session. The round-summary topic has
/// no anchor -- that dialog only exists once a round finishes, so this
/// step falls back to a plain centered bubble instead of needing extra
/// state just to preview it.
List<HelpTopic> flashcardStudyHelpTopics() {
  return [
    const HelpTopic(
      id: 'swipe-basics',
      title: 'How to answer a card',
      steps: [
        HelpStep(
          description:
              'Tap the card to flip between the question and the answer. '
              "Once the answer is showing, swipe right if you knew it or "
              "left if you didn't -- no need to use the buttons below.",
          anchorId: 'study-swipe-card',
        ),
        HelpStep(
          description: 'A color wash confirms your swipe before the next card '
              'appears, so you always know which way it registered.',
          anchorId: 'study-swipe-card',
          colorLegend: [
            HelpColorLegendEntry(
              color: Color(0xFF2EE59D),
              label: 'Knew it (swiped right)',
            ),
            HelpColorLegendEntry(
              color: Color(0xFFFF5B7A),
              label: "Didn't know (swiped left)",
            ),
          ],
        ),
      ],
    ),
    const HelpTopic(
      id: 'round-summary',
      title: 'The round summary',
      steps: [
        HelpStep(
          description: "Once you've gone through every card in the round, a "
              'summary shows how many you knew, almost knew, didn\'t '
              'know, or skipped -- with the option to immediately revise '
              'the ones you missed, or stop here.',
          scrimOpacity: HelpStep.lightScrim,
        ),
      ],
    ),
  ];
}
