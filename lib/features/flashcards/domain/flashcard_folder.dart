import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardFolder {
  static const rootId = '__root__';

  const FlashcardFolder({
    required this.id,
    required this.name,
    required this.parentId,
    required this.isDeleted,
    required this.deletedAt,
    required this.deletedAsCascade,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlashcardFolder.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data()!;

    return FlashcardFolder(
      id: document.id,
      name: data['name'] as String,
      parentId: data['parentId'] as String,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      deletedAsCascade: data['deletedAsCascade'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String name;
  final String parentId;
  final bool isDeleted;
  final DateTime? deletedAt;

  // False only for the folder the user directly deleted; true for every
  // folder/set that only ended up in the trash because an ancestor folder
  // was deleted. The Trash screen filters on this so it shows just the
  // one thing the user actually acted on, not every cascaded child too.
  final bool deletedAsCascade;
  final DateTime createdAt;
  final DateTime updatedAt;
}
