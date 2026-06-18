import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryFolder {
  static const rootId = '__root__';

  const LibraryFolder({
    required this.id,
    required this.name,
    required this.parentId,
    required this.isFavorite,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LibraryFolder.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return LibraryFolder(
      id: document.id,
      name: data['name'] as String,
      parentId: data['parentId'] as String,
      isFavorite: data['isFavorite'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String name;
  final String parentId;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
}
