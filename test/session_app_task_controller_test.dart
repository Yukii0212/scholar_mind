import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholar_mind/core/app_tasks/domain/app_task_type.dart';
import 'package:scholar_mind/core/app_tasks/providers/app_task_provider.dart';
import 'package:scholar_mind/core/app_tasks/services/app_task_controller.dart';
import 'package:scholar_mind/features/auth/providers/auth_provider.dart';

class _FakeUser extends Fake implements User {
  _FakeUser(this._uid);

  final String _uid;

  @override
  String get uid => _uid;
}

void main() {
  test('cooperative task session is cancelled when the account changes',
      () async {
    final sessionUserProvider = StateProvider<User?>(
      (_) => _FakeUser('account-a'),
    );
    final container = ProviderContainer(
      overrides: [
        activeUserProvider.overrideWith(
          (ref) => ref.watch(sessionUserProvider),
        ),
      ],
    );
    addTearDown(container.dispose);

    final started = Completer<AppTaskSession>();
    final release = Completer<void>();
    final future = container.read(appTaskControllerProvider).runSession<void>(
          id: 'session-test',
          type: AppTaskType.quizGeneration,
          title: 'Session test',
          task: (session, progress) async {
            started.complete(session);
            await release.future;
            session.throwIfChanged();
          },
        );

    final session = await started.future;
    expect(session.userId, 'account-a');
    expect(session.isCurrent, isTrue);

    container.read(sessionUserProvider.notifier).state = null;
    await Future<void>.delayed(Duration.zero);

    expect(session.isCurrent, isFalse);

    container.read(sessionUserProvider.notifier).state = _FakeUser('account-b');
    await Future<void>.delayed(Duration.zero);

    release.complete();

    await expectLater(
      future,
      throwsA(isA<AppTaskSessionChangedException>()),
    );
    expect(container.read(appTaskProvider), isEmpty);
  });
}
