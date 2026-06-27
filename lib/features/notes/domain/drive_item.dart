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

  bool get isImage =>
      switch (mimeType) {
        'image/jpeg' => true,
        'image/png' => true,
        'image/webp' => true,
        _ => false,
      };

  bool get isSupported {
    if (isFolder) return true;
    if (isImage) return true;

    switch (mimeType) {
      case 'application/pdf':
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      case 'application/vnd.ms-powerpoint':
      case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      case 'text/plain':
      case 'text/markdown':
        return true;

      default:
        return false;
    }
  }

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