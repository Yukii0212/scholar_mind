class DriveItem {
  const DriveItem({
    required this.id,
    required this.name,
    required this.mimeType,
  });

  final String id;
  final String name;
  final String mimeType;

  bool get isFolder =>
      mimeType == 'application/vnd.google-apps.folder';

  factory DriveItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return DriveItem(
      id: json['id'],
      name: json['name'] ?? 'Untitled',
      mimeType: json['mimeType'],
    );
  }
}