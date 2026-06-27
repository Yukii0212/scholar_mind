import 'package:cloud_firestore/cloud_firestore.dart';

import 'note_category.dart';

class NoteItem {
  const NoteItem({
    required this.id,
    required this.name,
    required this.folderId,
    required this.storagePath,
    required this.extension,
    required this.sizeBytes,
    required this.isInternal,
    required this.content,
    required this.category,
    required this.source,
    required this.isFavorite,
    required this.isDeleted,
    required this.cacheExpiresAt,
    required this.deletedAt,
    required this.createdAt,
    required this.lockedBy,
    required this.heartbeatAt,
    required this.lockExpiresAt,
  });

  factory NoteItem.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return NoteItem(
      id: document.id,
      name: data['name'] as String,
      folderId: data['folderId'] as String,
      storagePath: data['storagePath'] as String? ?? '',
      extension: data['extension'] as String? ?? '',
      sizeBytes: data['sizeBytes'] as int? ?? 0,
      content: data['content'] as String? ?? '',
      category: NoteCategory.fromKey(data['category'] as String),
      source: data['source'] as String,
      isFavorite: data['isFavorite'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isInternal: data['isInternal'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      cacheExpiresAt:
      data['cacheExpiresAt'] != null
          ? (data['cacheExpiresAt'] as Timestamp)
          .toDate()
          : null,
      lockedBy: data['lockedBy'] as String?,
      heartbeatAt:
      data['heartbeatAt'] != null
          ? (data['heartbeatAt'] as Timestamp)
          .toDate()
          : null,
      lockExpiresAt:
      data['lockExpiresAt'] != null
          ? (data['lockExpiresAt'] as Timestamp)
          .toDate()
          : null,
    );
  }

  final String id;
  final String name;
  final String folderId;
  final String storagePath;
  final String extension;
  final String source;
  final String content;
  final NoteCategory category;
  final int sizeBytes;
  final bool isFavorite;
  final bool isDeleted;
  final DateTime? cacheExpiresAt;
  final DateTime? deletedAt;
  final bool isInternal;
  final DateTime createdAt;
  final String? lockedBy;
  final DateTime? heartbeatAt;
  final DateTime? lockExpiresAt;
}
