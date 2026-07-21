import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

extension ThemeIconExtension on ThemeMode {
  String get appIcon {
    switch (this) {
      case ThemeMode.dark:
        return AppAssets.darkIcon;

      case ThemeMode.light:
        return AppAssets.scholarBlueIcon;

      case ThemeMode.system:
        return AppAssets.scholarBlueIcon;
    }
  }
}