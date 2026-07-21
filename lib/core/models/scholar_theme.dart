enum ScholarTheme {
  scholarBlue,
  sakuraPink,
  midnight,
}

extension ScholarThemeExtension on ScholarTheme {
  String get id {
    switch (this) {
      case ScholarTheme.scholarBlue:
        return 'scholar_blue';

      case ScholarTheme.sakuraPink:
        return 'sakura_pink';

      case ScholarTheme.midnight:
        return 'midnight';
    }
  }

  static ScholarTheme fromId(String? id) {
    switch (id) {
      case 'scholar_blue':
        return ScholarTheme.scholarBlue;

      case 'sakura_pink':
        return ScholarTheme.sakuraPink;

      case 'midnight':
      default:
        return ScholarTheme.midnight;
    }
  }
}