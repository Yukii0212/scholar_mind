import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../router/app_router.dart';

part 'deep_link_service.g.dart';

/// Listens for incoming `scholarmind://` deep links (both while the app is
/// already running and the one that launched a cold start) and routes them.
/// Instantiate once by watching this provider near the app root.
@Riverpod(keepAlive: true)
class DeepLinkListener extends _$DeepLinkListener {
  StreamSubscription<Uri>? _subscription;

  @override
  void build() {
    final appLinks = AppLinks();

    _subscription = appLinks.uriLinkStream.listen(_handleUri);

    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'scholarmind') {
      return;
    }

    if (uri.pathSegments.isEmpty) {
      return;
    }

    final shareId = uri.pathSegments.last;

    if (shareId.isEmpty) {
      return;
    }

    ref.read(appRouterProvider).go(
      '/import/share/$shareId',
    );
  }
}
