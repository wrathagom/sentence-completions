import 'package:flutter/material.dart';

import '../data/models/user_settings.dart';

/// Theme extension to store custom colors not in the standard ColorScheme
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color backgroundColor;

  const AppThemeExtension({required this.backgroundColor});

  @override
  AppThemeExtension copyWith({Color? backgroundColor}) {
    return AppThemeExtension(
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
    );
  }
}

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
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onTertiaryContainer,
      error: colors.error,
      onError: colors.onError,
      surface: isDark ? colors.surfaceDark : colors.surfaceLight,
      onSurface: isDark ? colors.onSurfaceDark : colors.onSurfaceLight,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      surfaceContainerHighest: isDark ? colors.surfaceContainerDark : colors.surfaceContainerLight,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
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
      extensions: [
        AppThemeExtension(
          backgroundColor: isDark ? colors.backgroundDark : colors.backgroundLight,
        ),
      ],
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

  // Catppuccin Mocha - Full palette
  static final _catppuccinMocha = _ColorPalette(
    primary: const Color(0xFFCBA6F7), // Mauve
    onPrimary: const Color(0xFF1E1E2E),
    secondary: const Color(0xFFF5C2E7), // Pink
    onSecondary: const Color(0xFF1E1E2E),
    tertiary: const Color(0xFF94E2D5), // Teal
    onTertiary: const Color(0xFF1E1E2E),
    tertiaryContainer: const Color(0xFF45475A),
    onTertiaryContainer: const Color(0xFF94E2D5),
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
    outline: const Color(0xFF6C7086), // Overlay0
    outlineVariant: const Color(0xFF585B70), // Surface2
    accentColors: const [
      Color(0xFFF5E0DC), // Rosewater
      Color(0xFFFAB387), // Peach
      Color(0xFFF9E2AF), // Yellow
      Color(0xFFA6E3A1), // Green
      Color(0xFF89DCEB), // Sky
      Color(0xFF89B4FA), // Blue
      Color(0xFFB4BEFE), // Lavender
    ],
  );

  // Catppuccin Latte - Full palette
  static final _catppuccinLatte = _ColorPalette(
    primary: const Color(0xFF8839EF), // Mauve
    onPrimary: const Color(0xFFEFF1F5),
    secondary: const Color(0xFFEA76CB), // Pink
    onSecondary: const Color(0xFFEFF1F5),
    tertiary: const Color(0xFF179299), // Teal
    onTertiary: const Color(0xFFEFF1F5),
    tertiaryContainer: const Color(0xFFE6E9EF),
    onTertiaryContainer: const Color(0xFF179299),
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
    outline: const Color(0xFF8C8FA1), // Overlay0
    outlineVariant: const Color(0xFFACB0BE), // Surface2
    accentColors: const [
      Color(0xFFDC8A78), // Rosewater
      Color(0xFFFE640B), // Peach
      Color(0xFFDF8E1D), // Yellow
      Color(0xFF40A02B), // Green
      Color(0xFF04A5E5), // Sky
      Color(0xFF1E66F5), // Blue
      Color(0xFF7287FD), // Lavender
    ],
  );

  // Gruvbox Dark - Full palette
  static final _gruvboxDark = _ColorPalette(
    primary: const Color(0xFFFE8019), // Orange
    onPrimary: const Color(0xFF282828),
    secondary: const Color(0xFFB8BB26), // Green
    onSecondary: const Color(0xFF282828),
    tertiary: const Color(0xFF83A598), // Aqua
    onTertiary: const Color(0xFF282828),
    tertiaryContainer: const Color(0xFF504945),
    onTertiaryContainer: const Color(0xFF83A598),
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
    outline: const Color(0xFF928374), // gray
    outlineVariant: const Color(0xFF665C54), // bg3
    accentColors: const [
      Color(0xFFFABD2F), // Yellow
      Color(0xFF8EC07C), // Aqua bright
      Color(0xFF458588), // Blue
      Color(0xFFD3869B), // Purple
      Color(0xFFCC241D), // Red dark
      Color(0xFFD79921), // Yellow dark
    ],
  );

  // Gruvbox Light - Full palette
  static final _gruvboxLight = _ColorPalette(
    primary: const Color(0xFFD65D0E), // Orange
    onPrimary: const Color(0xFFFBF1C7),
    secondary: const Color(0xFF79740E), // Green
    onSecondary: const Color(0xFFFBF1C7),
    tertiary: const Color(0xFF427B58), // Aqua
    onTertiary: const Color(0xFFFBF1C7),
    tertiaryContainer: const Color(0xFFEBDBB2),
    onTertiaryContainer: const Color(0xFF427B58),
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
    outline: const Color(0xFF7C6F64), // gray
    outlineVariant: const Color(0xFFBDAE93), // bg3
    accentColors: const [
      Color(0xFFB57614), // Yellow
      Color(0xFF689D6A), // Aqua
      Color(0xFF076678), // Blue
      Color(0xFF8F3F71), // Purple
      Color(0xFF9D0006), // Red dark
      Color(0xFFAF3A03), // Orange dark
    ],
  );

  // Solarized Dark - Full palette
  static final _solarizedDark = _ColorPalette(
    primary: const Color(0xFF268BD2), // Blue
    onPrimary: const Color(0xFF002B36),
    secondary: const Color(0xFF2AA198), // Cyan
    onSecondary: const Color(0xFF002B36),
    tertiary: const Color(0xFF859900), // Green
    onTertiary: const Color(0xFF002B36),
    tertiaryContainer: const Color(0xFF073642),
    onTertiaryContainer: const Color(0xFF859900),
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
    outline: const Color(0xFF657B83), // base00
    outlineVariant: const Color(0xFF586E75), // base01
    accentColors: const [
      Color(0xFFB58900), // Yellow
      Color(0xFFCB4B16), // Orange
      Color(0xFFD33682), // Magenta
      Color(0xFF6C71C4), // Violet
      Color(0xFF859900), // Green
      Color(0xFF2AA198), // Cyan
    ],
  );

  // Solarized Light - Full palette
  static final _solarizedLight = _ColorPalette(
    primary: const Color(0xFF268BD2), // Blue
    onPrimary: const Color(0xFFFDF6E3),
    secondary: const Color(0xFF2AA198), // Cyan
    onSecondary: const Color(0xFFFDF6E3),
    tertiary: const Color(0xFF859900), // Green
    onTertiary: const Color(0xFFFDF6E3),
    tertiaryContainer: const Color(0xFFEEE8D5),
    onTertiaryContainer: const Color(0xFF859900),
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
    outline: const Color(0xFF839496), // base0
    outlineVariant: const Color(0xFF93A1A1), // base1
    accentColors: const [
      Color(0xFFB58900), // Yellow
      Color(0xFFCB4B16), // Orange
      Color(0xFFD33682), // Magenta
      Color(0xFF6C71C4), // Violet
      Color(0xFF859900), // Green
      Color(0xFF2AA198), // Cyan
    ],
  );

  // Dracula - Full palette
  static final _dracula = _ColorPalette(
    primary: const Color(0xFFBD93F9), // Purple
    onPrimary: const Color(0xFF282A36),
    secondary: const Color(0xFFFF79C6), // Pink
    onSecondary: const Color(0xFF282A36),
    tertiary: const Color(0xFF50FA7B), // Green
    onTertiary: const Color(0xFF282A36),
    tertiaryContainer: const Color(0xFF44475A),
    onTertiaryContainer: const Color(0xFF50FA7B),
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
    outline: const Color(0xFF6272A4), // Comment
    outlineVariant: const Color(0xFF44475A), // Current Line
    accentColors: const [
      Color(0xFFFFB86C), // Orange
      Color(0xFFF1FA8C), // Yellow
      Color(0xFF8BE9FD), // Cyan
      Color(0xFF50FA7B), // Green
      Color(0xFFFF79C6), // Pink
      Color(0xFFBD93F9), // Purple
    ],
  );

  // Nord - Full palette
  static final _nord = _ColorPalette(
    primary: const Color(0xFF88C0D0), // Frost 3
    onPrimary: const Color(0xFF2E3440),
    secondary: const Color(0xFF81A1C1), // Frost 2
    onSecondary: const Color(0xFF2E3440),
    tertiary: const Color(0xFFA3BE8C), // Aurora Green
    onTertiary: const Color(0xFF2E3440),
    tertiaryContainer: const Color(0xFF434C5E),
    onTertiaryContainer: const Color(0xFFA3BE8C),
    primaryContainer: const Color(0xFF434C5E),
    onPrimaryContainer: const Color(0xFF88C0D0),
    secondaryContainer: const Color(0xFF434C5E),
    onSecondaryContainer: const Color(0xFF81A1C1),
    error: const Color(0xFFBF616A), // Aurora Red
    onError: const Color(0xFF2E3440),
    backgroundDark: const Color(0xFF2E3440), // Polar Night 0
    backgroundLight: const Color(0xFFECEFF4),
    surfaceDark: const Color(0xFF3B4252), // Polar Night 1
    surfaceLight: const Color(0xFFE5E9F0),
    onSurfaceDark: const Color(0xFFECEFF4), // Snow Storm 2
    onSurfaceLight: const Color(0xFF2E3440),
    surfaceContainerDark: const Color(0xFF434C5E), // Polar Night 2
    surfaceContainerLight: const Color(0xFFD8DEE9),
    outline: const Color(0xFF4C566A), // Polar Night 3
    outlineVariant: const Color(0xFF434C5E), // Polar Night 2
    accentColors: const [
      Color(0xFFD08770), // Aurora Orange
      Color(0xFFEBCB8B), // Aurora Yellow
      Color(0xFFA3BE8C), // Aurora Green
      Color(0xFFB48EAD), // Aurora Purple
      Color(0xFF5E81AC), // Frost 1
      Color(0xFF8FBCBB), // Frost 4
    ],
  );

  // One Dark - Full palette
  static final _oneDark = _ColorPalette(
    primary: const Color(0xFF61AFEF), // Blue
    onPrimary: const Color(0xFF282C34),
    secondary: const Color(0xFFC678DD), // Magenta
    onSecondary: const Color(0xFF282C34),
    tertiary: const Color(0xFF98C379), // Green
    onTertiary: const Color(0xFF282C34),
    tertiaryContainer: const Color(0xFF3E4451),
    onTertiaryContainer: const Color(0xFF98C379),
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
    outline: const Color(0xFF5C6370), // Comment
    outlineVariant: const Color(0xFF4B5263), // Selection
    accentColors: const [
      Color(0xFFE5C07B), // Yellow
      Color(0xFFD19A66), // Orange
      Color(0xFF56B6C2), // Cyan
      Color(0xFF98C379), // Green
      Color(0xFFE06C75), // Red
      Color(0xFFC678DD), // Magenta
    ],
  );

  // Tokyo Night - Full palette
  static final _tokyoNight = _ColorPalette(
    primary: const Color(0xFF7AA2F7), // Blue
    onPrimary: const Color(0xFF1A1B26),
    secondary: const Color(0xFFBB9AF7), // Purple
    onSecondary: const Color(0xFF1A1B26),
    tertiary: const Color(0xFF9ECE6A), // Green
    onTertiary: const Color(0xFF1A1B26),
    tertiaryContainer: const Color(0xFF292E42),
    onTertiaryContainer: const Color(0xFF9ECE6A),
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
    outline: const Color(0xFF565F89), // Comment
    outlineVariant: const Color(0xFF414868), // Terminal Black
    accentColors: const [
      Color(0xFFE0AF68), // Yellow
      Color(0xFFFF9E64), // Orange
      Color(0xFF73DACA), // Teal
      Color(0xFF7DCFFF), // Cyan
      Color(0xFFF7768E), // Red
      Color(0xFFBB9AF7), // Purple
    ],
  );

  // Rose Pine - Full palette
  static final _rosePine = _ColorPalette(
    primary: const Color(0xFFEB6F92), // Love
    onPrimary: const Color(0xFF191724),
    secondary: const Color(0xFFC4A7E7), // Iris
    onSecondary: const Color(0xFF191724),
    tertiary: const Color(0xFF9CCFD8), // Foam
    onTertiary: const Color(0xFF191724),
    tertiaryContainer: const Color(0xFF26233A),
    onTertiaryContainer: const Color(0xFF9CCFD8),
    primaryContainer: const Color(0xFF26233A),
    onPrimaryContainer: const Color(0xFFEB6F92),
    secondaryContainer: const Color(0xFF26233A),
    onSecondaryContainer: const Color(0xFFC4A7E7),
    error: const Color(0xFFEB6F92), // Love
    onError: const Color(0xFF191724),
    backgroundDark: const Color(0xFF191724), // Base
    backgroundLight: const Color(0xFFFAF4ED),
    surfaceDark: const Color(0xFF1F1D2E), // Surface
    surfaceLight: const Color(0xFFFFFAF3),
    onSurfaceDark: const Color(0xFFE0DEF4), // Text
    onSurfaceLight: const Color(0xFF575279),
    surfaceContainerDark: const Color(0xFF26233A), // Overlay
    surfaceContainerLight: const Color(0xFFF2E9E1),
    outline: const Color(0xFF6E6A86), // Muted
    outlineVariant: const Color(0xFF524F67), // Highlight Med
    accentColors: const [
      Color(0xFFEBBCBA), // Rose
      Color(0xFFF6C177), // Gold
      Color(0xFF31748F), // Pine
      Color(0xFF9CCFD8), // Foam
      Color(0xFFC4A7E7), // Iris
      Color(0xFFEB6F92), // Love
    ],
  );

  // Kanagawa - Full palette
  static final _kanagawa = _ColorPalette(
    primary: const Color(0xFF7E9CD8), // Crystal Blue
    onPrimary: const Color(0xFF1F1F28),
    secondary: const Color(0xFF957FB8), // Oniviolet
    onSecondary: const Color(0xFF1F1F28),
    tertiary: const Color(0xFF7AA89F), // Spring Green
    onTertiary: const Color(0xFF1F1F28),
    tertiaryContainer: const Color(0xFF2A2A37),
    onTertiaryContainer: const Color(0xFF7AA89F),
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
    outline: const Color(0xFF54546D), // Katana Gray
    outlineVariant: const Color(0xFF43436C), // Sumi Ink 6
    accentColors: const [
      Color(0xFFDCA561), // Autumn Yellow
      Color(0xFFFF5D62), // Peach Red
      Color(0xFF98BB6C), // Spring Green
      Color(0xFF7FB4CA), // Spring Blue
      Color(0xFFE46876), // Wave Red
      Color(0xFFFFA066), // Surimi Orange
    ],
  );
}

class _ColorPalette {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
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
  final Color outline;
  final Color outlineVariant;
  // Additional accent colors for charts, indicators, etc.
  final List<Color> accentColors;

  const _ColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
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
    required this.outline,
    required this.outlineVariant,
    required this.accentColors,
  });
}
