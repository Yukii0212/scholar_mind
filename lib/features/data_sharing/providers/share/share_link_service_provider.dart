import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/share_link_service.dart';

part 'share_link_service_provider.g.dart';

@riverpod
ShareLinkService shareLinkService(
    ShareLinkServiceRef ref,
    ) {
  return const ShareLinkService();
}