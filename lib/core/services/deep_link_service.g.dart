// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_link_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deepLinkListenerHash() => r'7b9f21647c8ab6897e5a60334fc7b2714b1e01bf';

/// Listens for incoming `scholarmind://` deep links (both while the app is
/// already running and the one that launched a cold start) and routes them.
/// Instantiate once by watching this provider near the app root.
///
/// Copied from [DeepLinkListener].
@ProviderFor(DeepLinkListener)
final deepLinkListenerProvider =
    NotifierProvider<DeepLinkListener, void>.internal(
  DeepLinkListener.new,
  name: r'deepLinkListenerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deepLinkListenerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeepLinkListener = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
