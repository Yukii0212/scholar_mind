import 'help_step.dart';

class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.title,
    required this.steps,
  });

  final String id;

  final String title;

  /// The tutorial for this topic, walked through in order with Back/Next
  /// controls. Almost always one step; use more when a question is best
  /// answered by highlighting several elements in sequence.
  final List<HelpStep> steps;
}
