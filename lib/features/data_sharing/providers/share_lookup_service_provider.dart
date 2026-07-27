import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/share_lookup_service.dart';

part 'share_lookup_service_provider.g.dart';

@riverpod
ShareLookupService shareLookupService(
    ShareLookupServiceRef ref,
    ) {
  return const ShareLookupService();
}