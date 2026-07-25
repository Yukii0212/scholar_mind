import '../domain/models/share_archive.dart';

abstract class ArchiveService {
  Future<List<int>> encode(
      ShareArchive archive,
      );

  Future<ShareArchive> decode(
      List<int> bytes,
      );
}