import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../notes/providers/google_classroom_provider.dart';
import '../../notes/services/file_cache_service.dart';

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
      ref.read(googleSignInProvider).signInSilently().catchError((_) => null),
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

/// The user whose backend resources may currently be accessed.
///
/// Firebase can still report the previous user while a sign-out is in
/// progress, and it reports a newly signed-in user before the surrounding UI
/// has finished the sign-in operation. Gating user-scoped providers on the
/// controller prevents old listeners from crossing account boundaries.
final activeUserProvider = Provider<User?>((ref) {
  if (ref.watch(authControllerProvider).isLoading) {
    return null;
  }

  return ref.watch(authStateProvider).valueOrNull;
});

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

      final userCredential =
          await ref.read(firebaseAuthProvider).signInWithCredential(credential);

      await userCredential.user?.getIdToken();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      ("GOOGLE SIGN IN ERROR: $e");

      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    ref.invalidate(classroomCoursesProvider);
    ref.invalidate(googleClassroomServiceProvider);

    try {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final googleSignIn = ref.read(googleSignInProvider);
      final userId = firebaseAuth.currentUser?.uid;

      await firebaseAuth.signOut();

      Object? cleanupError;
      StackTrace? cleanupStackTrace;

      if (userId != null) {
        try {
          await FileCacheService.clearUserCache(userId);
        } catch (error, stackTrace) {
          cleanupError = error;
          cleanupStackTrace = stackTrace;
        }
      }

      try {
        await googleSignIn.disconnect();
      } catch (_) {
        try {
          await googleSignIn.signOut();
        } catch (error, stackTrace) {
          cleanupError ??= error;
          cleanupStackTrace ??= stackTrace;
        }
      }

      if (cleanupError != null) {
        Error.throwWithStackTrace(cleanupError, cleanupStackTrace!);
      }

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
