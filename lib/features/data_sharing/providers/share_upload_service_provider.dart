import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/share_upload_service.dart';

part 'share_upload_service_provider.g.dart';

@riverpod
ShareUploadService shareUploadService(
    ShareUploadServiceRef ref,
    ) {
  return const ShareUploadService();
}