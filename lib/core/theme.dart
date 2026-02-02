import 'package:flutter/material.dart';

import '../data/models/user_settings.dart';

class AppTheme {
  static ThemeData getTheme(ColorTheme colorTheme, Brightness brightness) {
    final colors = _getColorPalette(colorTheme);
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      error: colors.error,
      onError: colors.onError,
      surface: isDark ? colors.surfaceDark : colors.surfaceLight,
      onSurface: isDark ? colors.onSurfaceDark : colors.onSurfaceLight,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      surfaceContainerHighest: isDark ? colors.surfaceContainerDark : colors.surfaceContainerLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? colors.backgroundDark : colors.backgroundLight,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? colors.backgroundDark : colors.backgroundLight,
        foregroundColor: isDark ? colors.onSurfaceDark : colors.onSurfaceLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? colors.surfaceDark : colors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colors.surfaceContainerDark : colors.surfaceContainerLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
    );
  }

  static _ColorPalette _getColorPalette(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.catppuccinMocha:
        return _catppuccinMocha;
      case ColorTheme.catppuccinLatte:
        return _catppuccinLatte;
      case ColorTheme.gruvboxDark:
        return _gruvboxDark;
      case ColorTheme.gruvboxLight:
        return _gruvboxLight;
      case ColorTheme.solarizedDark:
        return _solarizedDark;
      case ColorTheme.solarizedLight:
        return _solarizedLight;
      case ColorTheme.dracula:
        return _dracula;
      case ColorTheme.nord:
        return _nord;
      case ColorTheme.oneDark:
        return _oneDark;
      case ColorTheme.tokyoNight:
        return _tokyoNight;
      case ColorTheme.rosePine:
        return _rosePine;
      case ColorTheme.kanagawa:
        return _kanagawa;
    }
  }

  // Catppuccin Mocha
  static final _catppuccinMocha = _ColorPalette(
    primary: const Color(0xFFCBA6F7), // Mauve
    onPrimary: const Color(0xFF1E1E2E),
    secondary: const Color(0xFFF5C2E7), // Pink
    onSecondary: const Color(0xFF1E1E2E),
    primaryContainer: const Color(0xFF45475A),
    onPrimaryContainer: const Color(0xFFCBA6F7),
    secondaryContainer: const Color(0xFF45475A),
    onSecondaryContainer: const Color(0xFFF5C2E7),
    error: const Color(0xFFF38BA8), // Red
    onError: const Color(0xFF1E1E2E),
    backgroundDark: const Color(0xFF1E1E2E), // Base
    backgroundLight: const Color(0xFFEFF1F5),
    surfaceDark: const Color(0xFF313244), // Surface0
    surfaceLight: const Color(0xFFE6E9EF),
    onSurfaceDark: const Color(0xFFCDD6F4), // Text
    onSurfaceLight: const Color(0xFF4C4F69),
    surfaceContainerDark: const Color(0xFF45475A), // Surface1
    surfaceContainerLight: const Color(0xFFDCE0E8),
  );

  // Catppuccin Latte
  static final _catppuccinLatte = _ColorPalette(
    primary: const Color(0xFF8839EF), // Mauve
    onPrimary: const Color(0xFFEFF1F5),
    secondary: const Color(0xFFEA76CB), // Pink
    onSecondary: const Color(0xFFEFF1F5),
    primaryContainer: const Color(0xFFE6E9EF),
    onPrimaryContainer: const Color(0xFF8839EF),
    secondaryContainer: const Color(0xFFE6E9EF),
    onSecondaryContainer: const Color(0xFFEA76CB),
    error: const Color(0xFFD20F39), // Red
    onError: const Color(0xFFEFF1F5),
    backgroundDark: const Color(0xFF1E1E2E),
    backgroundLight: const Color(0xFFEFF1F5), // Base
    surfaceDark: const Color(0xFF313244),
    surfaceLight: const Color(0xFFE6E9EF), // Surface0
    onSurfaceDark: const Color(0xFFCDD6F4),
    onSurfaceLight: const Color(0xFF4C4F69), // Text
    surfaceContainerDark: const Color(0xFF45475A),
    surfaceContainerLight: const Color(0xFFDCE0E8), // Surface1
  );

  // Gruvbox Dark
  static final _gruvboxDark = _ColorPalette(
    primary: const Color(0xFFFE8019), // Orange
    onPrimary: const Color(0xFF282828),
    secondary: const Color(0xFFB8BB26), // Green
    onSecondary: const Color(0xFF282828),
    primaryContainer: const Color(0xFF504945),
    onPrimaryContainer: const Color(0xFFFE8019),
    secondaryContainer: const Color(0xFF504945),
    onSecondaryContainer: const Color(0xFFB8BB26),
    error: const Color(0xFFFB4934), // Red
    onError: const Color(0xFF282828),
    backgroundDark: const Color(0xFF282828), // bg0
    backgroundLight: const Color(0xFFFBF1C7),
    surfaceDark: const Color(0xFF3C3836), // bg1
    surfaceLight: const Color(0xFFEBDBB2),
    onSurfaceDark: const Color(0xFFEBDBB2), // fg
    onSurfaceLight: const Color(0xFF3C3836),
    surfaceContainerDark: const Color(0xFF504945), // bg2
    surfaceContainerLight: const Color(0xFFD5C4A1),
  );

  // Gruvbox Light
  static final _gruvboxLight = _ColorPalette(
    primary: const Color(0xFFD65D0E), // Orange
    onPrimary: const Color(0xFFFBF1C7),
    secondary: const Color(0xFF79740E), // Green
    onSecondary: const Color(0xFFFBF1C7),
    primaryContainer: const Color(0xFFEBDBB2),
    onPrimaryContainer: const Color(0xFFD65D0E),
    secondaryContainer: const Color(0xFFEBDBB2),
    onSecondaryContainer: const Color(0xFF79740E),
    error: const Color(0xFFCC241D), // Red
    onError: const Color(0xFFFBF1C7),
    backgroundDark: const Color(0xFF282828),
    backgroundLight: const Color(0xFFFBF1C7), // bg0
    surfaceDark: const Color(0xFF3C3836),
    surfaceLight: const Color(0xFFEBDBB2), // bg1
    onSurfaceDark: const Color(0xFFEBDBB2),
    onSurfaceLight: const Color(0xFF3C3836), // fg
    surfaceContainerDark: const Color(0xFF504945),
    surfaceContainerLight: const Color(0xFFD5C4A1), // bg2
  );

  // Solarized Dark
  static final _solarizedDark = _ColorPalette(
    primary: const Color(0xFF268BD2), // Blue
    onPrimary: const Color(0xFF002B36),
    secondary: const Color(0xFF2AA198), // Cyan
    onSecondary: const Color(0xFF002B36),
    primaryContainer: const Color(0xFF073642),
    onPrimaryContainer: const Color(0xFF268BD2),
    secondaryContainer: const Color(0xFF073642),
    onSecondaryContainer: const Color(0xFF2AA198),
    error: const Color(0xFFDC322F), // Red
    onError: const Color(0xFF002B36),
    backgroundDark: const Color(0xFF002B36), // base03
    backgroundLight: const Color(0xFFFDF6E3),
    surfaceDark: const Color(0xFF073642), // base02
    surfaceLight: const Color(0xFFEEE8D5),
    onSurfaceDark: const Color(0xFF839496), // base0
    onSurfaceLight: const Color(0xFF657B83),
    surfaceContainerDark: const Color(0xFF586E75), // base01
    surfaceContainerLight: const Color(0xFFEEE8D5),
  );

  // Solarized Light
  static final _solarizedLight = _ColorPalette(
    primary: const Color(0xFF268BD2), // Blue
    onPrimary: const Color(0xFFFDF6E3),
    secondary: const Color(0xFF2AA198), // Cyan
    onSecondary: const Color(0xFFFDF6E3),
    primaryContainer: const Color(0xFFEEE8D5),
    onPrimaryContainer: const Color(0xFF268BD2),
    secondaryContainer: const Color(0xFFEEE8D5),
    onSecondaryContainer: const Color(0xFF2AA198),
    error: const Color(0xFFDC322F), // Red
    onError: const Color(0xFFFDF6E3),
    backgroundDark: const Color(0xFF002B36),
    backgroundLight: const Color(0xFFFDF6E3), // base3
    surfaceDark: const Color(0xFF073642),
    surfaceLight: const Color(0xFFEEE8D5), // base2
    onSurfaceDark: const Color(0xFF839496),
    onSurfaceLight: const Color(0xFF657B83), // base00
    surfaceContainerDark: const Color(0xFF586E75),
    surfaceContainerLight: const Color(0xFFEEE8D5), // base2
  );

  // Dracula
  static final _dracula = _ColorPalette(
    primary: const Color(0xFFBD93F9), // Purple
    onPrimary: const Color(0xFF282A36),
    secondary: const Color(0xFFFF79C6), // Pink
    onSecondary: const Color(0xFF282A36),
    primaryContainer: const Color(0xFF44475A),
    onPrimaryContainer: const Color(0xFFBD93F9),
    secondaryContainer: const Color(0xFF44475A),
    onSecondaryContainer: const Color(0xFFFF79C6),
    error: const Color(0xFFFF5555), // Red
    onError: const Color(0xFF282A36),
    backgroundDark: const Color(0xFF282A36), // Background
    backgroundLight: const Color(0xFFF8F8F2),
    surfaceDark: const Color(0xFF44475A), // Current Line
    surfaceLight: const Color(0xFFE8E8E2),
    onSurfaceDark: const Color(0xFFF8F8F2), // Foreground
    onSurfaceLight: const Color(0xFF282A36),
    surfaceContainerDark: const Color(0xFF6272A4), // Comment
    surfaceContainerLight: const Color(0xFFD8D8D2),
  );

  // Nord
  static final _nord = _ColorPalette(
    primary: const Color(0xFF88C0D0), // Frost
    onPrimary: const Color(0xFF2E3440),
    secondary: const Color(0xFF81A1C1), // Frost
    onSecondary: const Color(0xFF2E3440),
    primaryContainer: const Color(0xFF434C5E),
    onPrimaryContainer: const Color(0xFF88C0D0),
    secondaryContainer: const Color(0xFF434C5E),
    onSecondaryContainer: const Color(0xFF81A1C1),
    error: const Color(0xFFBF616A), // Aurora Red
    onError: const Color(0xFF2E3440),
    backgroundDark: const Color(0xFF2E3440), // Polar Night
    backgroundLight: const Color(0xFFECEFF4),
    surfaceDark: const Color(0xFF3B4252), // Polar Night
    surfaceLight: const Color(0xFFE5E9F0),
    onSurfaceDark: const Color(0xFFECEFF4), // Snow Storm
    onSurfaceLight: const Color(0xFF2E3440),
    surfaceContainerDark: const Color(0xFF434C5E), // Polar Night
    surfaceContainerLight: const Color(0xFFD8DEE9),
  );

  // One Dark
  static final _oneDark = _ColorPalette(
    primary: const Color(0xFF61AFEF), // Blue
    onPrimary: const Color(0xFF282C34),
    secondary: const Color(0xFFC678DD), // Magenta
    onSecondary: const Color(0xFF282C34),
    primaryContainer: const Color(0xFF3E4451),
    onPrimaryContainer: const Color(0xFF61AFEF),
    secondaryContainer: const Color(0xFF3E4451),
    onSecondaryContainer: const Color(0xFFC678DD),
    error: const Color(0xFFE06C75), // Red
    onError: const Color(0xFF282C34),
    backgroundDark: const Color(0xFF282C34), // Background
    backgroundLight: const Color(0xFFFAFAFA),
    surfaceDark: const Color(0xFF21252B), // Gutter
    surfaceLight: const Color(0xFFEAEAEA),
    onSurfaceDark: const Color(0xFFABB2BF), // Foreground
    onSurfaceLight: const Color(0xFF383A42),
    surfaceContainerDark: const Color(0xFF3E4451), // Selection
    surfaceContainerLight: const Color(0xFFDDDDDD),
  );

  // Tokyo Night
  static final _tokyoNight = _ColorPalette(
    primary: const Color(0xFF7AA2F7), // Blue
    onPrimary: const Color(0xFF1A1B26),
    secondary: const Color(0xFFBB9AF7), // Purple
    onSecondary: const Color(0xFF1A1B26),
    primaryContainer: const Color(0xFF292E42),
    onPrimaryContainer: const Color(0xFF7AA2F7),
    secondaryContainer: const Color(0xFF292E42),
    onSecondaryContainer: const Color(0xFFBB9AF7),
    error: const Color(0xFFF7768E), // Red
    onError: const Color(0xFF1A1B26),
    backgroundDark: const Color(0xFF1A1B26), // Background
    backgroundLight: const Color(0xFFD5D6DB),
    surfaceDark: const Color(0xFF24283B), // Background Alt
    surfaceLight: const Color(0xFFC5C6CB),
    onSurfaceDark: const Color(0xFFC0CAF5), // Foreground
    onSurfaceLight: const Color(0xFF343B59),
    surfaceContainerDark: const Color(0xFF292E42), // Selection
    surfaceContainerLight: const Color(0xFFB5B6BB),
  );

  // Rose Pine
  static final _rosePine = _ColorPalette(
    primary: const Color(0xFFEB6F92), // Love
    onPrimary: const Color(0xFF191724),
    secondary: const Color(0xFFC4A7E7), // Iris
    onSecondary: const Color(0xFF191724),
    primaryContainer: const Color(0xFF26233A),
    onPrimaryContainer: const Color(0xFFEB6F92),
    secondaryContainer: const Color(0xFF26233A),
    onSecondaryContainer: const Color(0xFFC4A7E7),
    error: const Color(0xFFEB6F92), // Love (also used for errors)
    onError: const Color(0xFF191724),
    backgroundDark: const Color(0xFF191724), // Base
    backgroundLight: const Color(0xFFFAF4ED),
    surfaceDark: const Color(0xFF1F1D2E), // Surface
    surfaceLight: const Color(0xFFFFFAF3),
    onSurfaceDark: const Color(0xFFE0DEF4), // Text
    onSurfaceLight: const Color(0xFF575279),
    surfaceContainerDark: const Color(0xFF26233A), // Overlay
    surfaceContainerLight: const Color(0xFFF2E9E1),
  );

  // Kanagawa
  static final _kanagawa = _ColorPalette(
    primary: const Color(0xFF7E9CD8), // Crystal Blue
    onPrimary: const Color(0xFF1F1F28),
    secondary: const Color(0xFF957FB8), // Oniviolet
    onSecondary: const Color(0xFF1F1F28),
    primaryContainer: const Color(0xFF2A2A37),
    onPrimaryContainer: const Color(0xFF7E9CD8),
    secondaryContainer: const Color(0xFF2A2A37),
    onSecondaryContainer: const Color(0xFF957FB8),
    error: const Color(0xFFC34043), // Autumn Red
    onError: const Color(0xFF1F1F28),
    backgroundDark: const Color(0xFF1F1F28), // Sumi Ink 3
    backgroundLight: const Color(0xFFF2ECBC),
    surfaceDark: const Color(0xFF2A2A37), // Sumi Ink 4
    surfaceLight: const Color(0xFFE8E2B7),
    onSurfaceDark: const Color(0xFFDCD7BA), // Fuji White
    onSurfaceLight: const Color(0xFF54546D),
    surfaceContainerDark: const Color(0xFF363646), // Sumi Ink 5
    surfaceContainerLight: const Color(0xFFDED8A8),
  );
}

class _ColorPalette {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color error;
  final Color onError;
  final Color backgroundDark;
  final Color backgroundLight;
  final Color surfaceDark;
  final Color surfaceLight;
  final Color onSurfaceDark;
  final Color onSurfaceLight;
  final Color surfaceContainerDark;
  final Color surfaceContainerLight;

  const _ColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.error,
    required this.onError,
    required this.backgroundDark,
    required this.backgroundLight,
    required this.surfaceDark,
    required this.surfaceLight,
    required this.onSurfaceDark,
    required this.onSurfaceLight,
    required this.surfaceContainerDark,
    required this.surfaceContainerLight,
  });
}
