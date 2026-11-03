import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholar_mind/features/auth/providers/auth_provider.dart';
import 'package:scholar_mind/features/notes/services/file_cache_service.dart';

class _FakeUser extends Fake implements User {
  _FakeUser(this._uid);

  final String _uid;

  @override
  String get uid => _uid;
}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  _FakeFirebaseAuth({required this.user, this.signOutError});

  final User? user;
  final Object? signOutError;
  var signOutCalls = 0;

  @override
  User? get currentUser => user;

  @override
  Future<void> signOut() async {
    signOutCalls += 1;

    if (signOutError case final error?) {
      throw error;
    }
  }
}

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {
  var disconnectCalls = 0;
  var signOutCalls = 0;

  @override
  Future<GoogleSignInAccount?> disconnect() async {
    disconnectCalls += 1;
    return null;
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    signOutCalls += 1;
    return null;
  }
}

void main() {
  late Directory cacheDirectory;

  setUp(() async {
    cacheDirectory = await Directory.systemTemp.createTemp(
      'scholar_mind_note_cache_auth_',
    );
    FileCacheService.setCacheDirectoryForTesting(cacheDirectory);
  });

  tearDown(() async {
    FileCacheService.setCacheDirectoryForTesting(null);

    if (await cacheDirectory.exists()) {
      await cacheDirectory.delete(recursive: true);
    }
  });

  test('successful logout clears only the signed-in account cache', () async {
    final accountAFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: 'source.txt',
      bytes: const [1],
    );
    final accountBFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-b/notes/note-b/source.txt',
      fileName: 'source.txt',
      bytes: const [2],
    );
    final firebaseAuth = _FakeFirebaseAuth(user: _FakeUser('account-a'));
    final googleSignIn = _FakeGoogleSignIn();
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(firebaseAuth),
        googleSignInProvider.overrideWithValue(googleSignIn),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).signOut();

    expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    expect(firebaseAuth.signOutCalls, 1);
    expect(googleSignIn.disconnectCalls, 1);
    expect(await accountAFile.exists(), isFalse);
    expect(await accountBFile.exists(), isTrue);
  });

  test('Firebase logout failures remain visible and preserve cache', () async {
    final cachedFile = await FileCacheService.saveBytes(
      storagePath: 'users/account-a/notes/note-a/source.txt',
      fileName: 'source.txt',
      bytes: const [1],
    );
    final failure = StateError('Firebase sign-out failed');
    final firebaseAuth = _FakeFirebaseAuth(
      user: _FakeUser('account-a'),
      signOutError: failure,
    );
    final googleSignIn = _FakeGoogleSignIn();
    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(firebaseAuth),
        googleSignInProvider.overrideWithValue(googleSignIn),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).signOut();

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, same(failure));
    expect(googleSignIn.disconnectCalls, 0);
    expect(await cachedFile.exists(), isTrue);
  });
}
