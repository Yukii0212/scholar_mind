class DriveItem {
  const DriveItem({
    required this.id,
    required this.name,
    required this.mimeType,
    this.shortcutTargetId,
    this.shortcutTargetMimeType,
  });

  final String id;
  final String name;
  final String mimeType;
  final String? shortcutTargetId;
  final String? shortcutTargetMimeType;

  bool get isFolder =>
      effectiveMimeType == 'application/vnd.google-apps.folder';

  bool get isImage =>
      switch (effectiveMimeType) {
        'image/jpeg' => true,
        'image/png' => true,
        'image/webp' => true,
        _ => false,
      };

  bool get isShortcut =>
      mimeType == 'application/vnd.google-apps.shortcut';

  String get effectiveMimeType =>
      isShortcut
          ? (shortcutTargetMimeType ?? mimeType)
          : mimeType;

  String get effectiveId =>
      isShortcut
          ? (shortcutTargetId ?? id)
          : id;

  bool get isSupported {
    if (isFolder) return true;
    if (isImage) return true;

    switch (effectiveMimeType) {
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
      shortcutTargetId:
      json['shortcutDetails']?['targetId'],
      shortcutTargetMimeType:
      json['shortcutDetails']?['targetMimeType'],
    );
  }
}