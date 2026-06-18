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
    required this.category,
    required this.source,
    required this.createdAt,
  });

  factory NoteItem.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return NoteItem(
      id: document.id,
      name: data['name'] as String,
      folderId: data['folderId'] as String,
      storagePath: data['storagePath'] as String,
      extension: data['extension'] as String? ?? '',
      sizeBytes: data['sizeBytes'] as int,
      category: NoteCategory.fromKey(data['category'] as String),
      source: data['source'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String name;
  final String folderId;
  final String storagePath;
  final String extension;
  final int sizeBytes;
  final NoteCategory category;
  final String source;
  final DateTime createdAt;
}
