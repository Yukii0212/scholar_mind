import '../../help/domain/help_step.dart';
import '../../help/domain/help_topic.dart';

/// Help topics for the login screen
/// (`lib/features/auth/screens/login_screen.dart`).
/// The anchor lives on the "Continue with Google" button itself
/// (`google-signin-button`).
///
/// Kept deliberately small: the screen is a single button, so one topic
/// covering what it does — plus the one real quirk worth flagging — is
/// enough. See `lib/features/auth/providers/auth_provider.dart`
/// (`AuthWarmup`) for the actual mitigation described in step two.
List<HelpTopic> authHelpTopics() {
  return const [
    HelpTopic(
      id: 'google-sign-in',
      title: 'Signing in with Google',
      steps: [
        HelpStep(
          description:
              'ScholarMind signs you in with your Google account — there\'s '
              'no separate password to create. Tap "Continue with Google" '
              'and pick the account you want to use.',
          anchorId: 'google-signin-button',
        ),
        HelpStep(
          description:
              'The app prepares this connection as soon as it opens, so '
              'sign-in should respond right away. If your very first tap '
              'after opening the app doesn\'t seem to do anything, give it '
              'a moment rather than tapping repeatedly — the button also '
              'disables itself and shows a spinner while a sign-in is in '
              'progress.',
          anchorId: 'google-signin-button',
          scrimOpacity: HelpStep.lightScrim,
        ),
      ],
    ),
  ];
}
