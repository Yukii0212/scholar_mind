import '../domain/models/share/share_archive.dart';
import '../domain/models/share/share_manifest.dart';
import '../domain/models/share/share_resource.dart';

class ArchiveBuilderService {
  const ArchiveBuilderService();

  ShareArchive build(
      List<ShareResource> resources,
      ) {
    return ShareArchive(
      manifest: ShareManifest(
        archiveVersion: 1,
        createdAt: DateTime.now(),
        resourceCount: resources.length,
      ),
      resources: resources,
    );
  }
}