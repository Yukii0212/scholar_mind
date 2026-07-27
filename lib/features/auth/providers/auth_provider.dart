import 'dart:async';

import '../../notes/providers/google_classroom_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'auth_provider.g.dart';

/// Primes the Google Sign-In platform channel on app start. Without this,
/// the very first `signIn()` call after a cold start (or after a full
/// `disconnect()`) can silently return before the native picker result is
/// delivered, which is why the button sometimes needs to be tapped twice.
/// Watch this once near the app root to trigger it.
@Riverpod(keepAlive: true)
class AuthWarmup extends _$AuthWarmup {
  @override
  void build() {
    unawaited(
      ref
          .read(googleSignInProvider)
          .signInSilently()
          .catchError((_) => null),
    );
  }
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(
    GoogleSignInRef ref,
    ) {
  return GoogleSignIn(
    scopes: const [
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly',
      'https://www.googleapis.com/auth/drive.readonly',
    ],
  );
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final googleUser = await ref.read(googleSignInProvider).signIn();

      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      state = const AsyncValue.data(null);
    }
    catch (e, st) {
      ("GOOGLE SIGN IN ERROR: $e");

      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await ref.read(firebaseAuthProvider).signOut();

      try {
        await ref.read(googleSignInProvider).disconnect();
      } catch (_) {
      }

      await ref.read(googleSignInProvider).signOut();

      ref.invalidate(classroomCoursesProvider);
      ref.invalidate(googleClassroomServiceProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = const AsyncValue.data(null);
    }
  }
}
