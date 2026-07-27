import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/share_archive_deserializer.dart';

part 'share_archive_deserializer_provider.g.dart';

@riverpod
ShareArchiveDeserializer
shareArchiveDeserializer(
    ShareArchiveDeserializerRef ref,
    ) {
  return const ShareArchiveDeserializer();
}