import 'share_manifest.dart';
import 'share_resource.dart';

class ShareArchive {
  const ShareArchive({
    required this.manifest,
    required this.resources,
  });

  final ShareManifest manifest;

  final List<ShareResource> resources;

  ShareArchive withResources(
    List<ShareResource> resources,
  ) {
    return ShareArchive(
      manifest: ShareManifest(
        archiveVersion: manifest.archiveVersion,
        createdAt: manifest.createdAt,
        resourceCount: resources.length,
      ),
      resources: List<ShareResource>.unmodifiable(resources),
    );
  }
}
