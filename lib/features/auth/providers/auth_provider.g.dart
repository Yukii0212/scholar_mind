// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'c8e57c3e164ad1c2cad48c4508e47f6097e350a7';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = Provider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseAuthRef = ProviderRef<FirebaseAuth>;
String _$googleSignInHash() => r'8ef9864663d54d279ed27b1e60e5f2bac53d87e5';

/// See also [googleSignIn].
@ProviderFor(googleSignIn)
final googleSignInProvider = Provider<GoogleSignIn>.internal(
  googleSignIn,
  name: r'googleSignInProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$googleSignInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GoogleSignInRef = ProviderRef<GoogleSignIn>;
String _$authStateHash() => r'fbcf3795f8dc7890f79b8049b371ff8c9a570d87';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$authWarmupHash() => r'c18577c8d59da1d559faaf9b5f9e8dd5c8e2a6e4';

/// Primes the Google Sign-In platform channel on app start. Without this,
/// the very first `signIn()` call after a cold start (or after a full
/// `disconnect()`) can silently return before the native picker result is
/// delivered, which is why the button sometimes needs to be tapped twice.
/// Watch this once near the app root to trigger it.
///
/// Copied from [AuthWarmup].
@ProviderFor(AuthWarmup)
final authWarmupProvider = NotifierProvider<AuthWarmup, void>.internal(
  AuthWarmup.new,
  name: r'authWarmupProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authWarmupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthWarmup = Notifier<void>;
String _$authControllerHash() => r'34659bf18ad9059ec93b4f77dd05eb29a0eaab52';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
