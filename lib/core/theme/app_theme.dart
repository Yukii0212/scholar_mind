import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_design.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get scholarBlueLight => _theme(
        palette: ScholarPalettes.scholarBlue,
        brightness: Brightness.light,
      );

  static ThemeData get scholarBlueDark => _theme(
        palette: ScholarPalettes.scholarBlue.copyWith(
          canvas: const Color(0xFF061127),
          canvasDeep: const Color(0xFF020713),
          panel: const Color(0xFF0B1730),
          panelStrong: const Color(0xFF102044),
          stroke: const Color(0xFF263F76),
          textMuted: const Color(0xFFAABBEA),
        ),
        brightness: Brightness.dark,
      );

  static ThemeData get sakuraPinkDark => _theme(
        palette: ScholarPalettes.sakuraPink,
        brightness: Brightness.dark,
      );

  static ThemeData get midnight => _theme(
        palette: ScholarPalettes.midnight,
        brightness: Brightness.dark,
      );

  static ThemeData _theme({
    required ScholarPalette palette,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.poppinsTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.brandStart,
      onPrimary: Colors.white,
      secondary: palette.brandEnd,
      onSecondary: Colors.white,
      tertiary: palette.accent,
      onTertiary: const Color(0xFF111827),
      error: const Color(0xFFFF5B7A),
      onError: Colors.white,
      surface: palette.panel,
      onSurface: isDark ? const Color(0xFFF6F8FF) : const Color(0xFF101729),
      surfaceContainerHighest: palette.panelStrong,
      outline: palette.stroke,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.canvas,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      extensions: [palette],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.panel,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.stroke.withValues(alpha: 0.78)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.stroke.withValues(alpha: 0.7),
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textMuted,
        textColor: scheme.onSurface,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: palette.textMuted,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.panel.withValues(alpha: 0.96),
        elevation: 0,
        indicatorColor: palette.brandStart.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.poppins(
            fontSize: 11,
            fontWeight:
                states.contains(WidgetState.selected) ? FontWeight.w600 : null,
            color: states.contains(WidgetState.selected)
                ? palette.brandEnd
                : palette.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.brandEnd
                : palette.textMuted,
            size: 22,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.panel.withValues(alpha: 0.96),
        indicatorColor: palette.brandStart.withValues(alpha: 0.22),
        selectedIconTheme: IconThemeData(color: palette.brandEnd),
        unselectedIconTheme: IconThemeData(color: palette.textMuted),
        selectedLabelTextStyle: TextStyle(
          color: palette.brandEnd,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(color: palette.textMuted),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: palette.brandStart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: palette.brandStart,
          minimumSize: const Size(48, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brandEnd,
          side: BorderSide(color: palette.stroke),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.brandEnd,
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.panelStrong.withValues(alpha: isDark ? 0.56 : 0.9),
        hintStyle: TextStyle(color: palette.textMuted),
        labelStyle: TextStyle(color: palette.textMuted),
        prefixIconColor: palette.textMuted,
        suffixIconColor: palette.textMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.brandEnd, width: 1.4),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.brandStart.withValues(alpha: 0.2)
                : palette.panelStrong.withValues(alpha: 0.5),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.brandEnd
                : palette.textMuted,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: palette.stroke)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.panelStrong,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.stroke),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.stroke),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.panelStrong,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.brandStart,
        linearTrackColor: palette.stroke.withValues(alpha: 0.45),
      ),
    );
  }
}
