import '../share/share_archive.dart';

class ImportRequest {
  const ImportRequest({
    required this.userId,
    required this.archive,
  });

  final String userId;
  final ShareArchive archive;
}