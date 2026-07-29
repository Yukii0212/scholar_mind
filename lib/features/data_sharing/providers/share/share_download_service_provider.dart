import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/share_download_service.dart';

part 'share_download_service_provider.g.dart';

@riverpod
ShareDownloadService shareDownloadService(
    ShareDownloadServiceRef ref,
    ) {
  return const ShareDownloadService();
}