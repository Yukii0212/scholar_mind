import 'share_manifest.dart';
import 'share_resource.dart';

class ShareArchive {
  const ShareArchive({
    required this.manifest,
    required this.resources,
  });

  final ShareManifest manifest;

  final List<ShareResource> resources;
}