import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scholar_mind/features/auth/providers/auth_provider.dart';

class _FakeUser extends Fake implements User {
  _FakeUser(this._uid);

  final String _uid;

  @override
  String get uid => _uid;
}

class _FakeAuthController extends AuthController {
  @override
  FutureOr<void> build() {}

  void setTransitioning(bool transitioning) {
    state = transitioning
        ? const AsyncValue.loading()
        : const AsyncValue.data(null);
  }
}

void main() {
  test('active user is hidden during account transitions', () async {
    final user = _FakeUser('account-a');
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(user)),
        authControllerProvider.overrideWith(_FakeAuthController.new),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authStateProvider.future);

    expect(container.read(activeUserProvider)?.uid, 'account-a');

    final controller = container.read(authControllerProvider.notifier)
        as _FakeAuthController;

    controller.setTransitioning(true);

    expect(container.read(activeUserProvider), isNull);

    controller.setTransitioning(false);

    expect(container.read(activeUserProvider)?.uid, 'account-a');
  });
}
