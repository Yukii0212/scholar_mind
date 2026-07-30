import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../domain/models/share/share_link_record.dart';
import 'share_link_service_provider.dart';

final myShareLinksProvider = StreamProvider<List<ShareLinkRecord>>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;

  if (userId == null) {
    return Stream.value(const []);
  }

  return ref.watch(shareLinkServiceProvider).watchMyLinks(userId);
});
