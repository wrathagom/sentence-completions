enum AppLockType { none, biometric, pin }

enum ThemeModePreference { system, light, dark }

enum TitleBarStyle { system, minimal, none }

enum GuidedModeType { off, keyword, intelligent }

extension GuidedModeTypeExtension on GuidedModeType {
  String get displayName {
    switch (this) {
      case GuidedModeType.off:
        return 'Off';
      case GuidedModeType.keyword:
        return 'Keyword-based';
      case GuidedModeType.intelligent:
        return 'Intelligent (AI)';
    }
  }

  String get description {
    switch (this) {
      case GuidedModeType.off:
        return 'No suggestions after completing';
      case GuidedModeType.keyword:
        return 'Suggestions based on keywords in your text';
      case GuidedModeType.intelligent:
        return 'AI-generated personalized suggestions';
    }
  }
}

enum ColorTheme {
  catppuccinMocha,
  catppuccinLatte,
  gruvboxDark,
  gruvboxLight,
  solarizedDark,
  solarizedLight,
  dracula,
  nord,
  oneDark,
  tokyoNight,
  rosePine,
  kanagawa,
}

enum HomeAnalyticsWidget {
  wordCloud,
  categoryPieChart,
  statsRow,
}

enum CardGlowIntensity {
  none,
  subtle,
  medium,
  strong,
}

extension CardGlowIntensityExtension on CardGlowIntensity {
  String get displayName {
    switch (this) {
      case CardGlowIntensity.none:
        return 'None';
      case CardGlowIntensity.subtle:
        return 'Subtle';
      case CardGlowIntensity.medium:
        return 'Medium';
      case CardGlowIntensity.strong:
        return 'Strong';
    }
  }

  double get blurRadius {
    switch (this) {
      case CardGlowIntensity.none:
        return 0;
      case CardGlowIntensity.subtle:
        return 6;
      case CardGlowIntensity.medium:
        return 10;
      case CardGlowIntensity.strong:
        return 16;
    }
  }

  double get opacity {
    switch (this) {
      case CardGlowIntensity.none:
        return 0;
      case CardGlowIntensity.subtle:
        return 0.10;
      case CardGlowIntensity.medium:
        return 0.18;
      case CardGlowIntensity.strong:
        return 0.25;
    }
  }
}

enum BackgroundPattern {
  none,
  noise,
  dots,
  diagonalLines,
}

extension BackgroundPatternExtension on BackgroundPattern {
  String get displayName {
    switch (this) {
      case BackgroundPattern.none:
        return 'None';
      case BackgroundPattern.noise:
        return 'Noise';
      case BackgroundPattern.dots:
        return 'Dot Grid';
      case BackgroundPattern.diagonalLines:
        return 'Diagonal Lines';
    }
  }
}

enum PageTransitionStyle {
  none,
  fade,
  slide,
}

extension PageTransitionStyleExtension on PageTransitionStyle {
  String get displayName {
    switch (this) {
      case PageTransitionStyle.none:
        return 'None';
      case PageTransitionStyle.fade:
        return 'Fade';
      case PageTransitionStyle.slide:
        return 'Slide';
    }
  }
}

extension HomeAnalyticsWidgetExtension on HomeAnalyticsWidget {
  String get displayName {
    switch (this) {
      case HomeAnalyticsWidget.wordCloud:
        return 'Word Cloud';
      case HomeAnalyticsWidget.categoryPieChart:
        return 'Category Pie Chart';
      case HomeAnalyticsWidget.statsRow:
        return 'Stats Row';
    }
  }
}

extension ColorThemeExtension on ColorTheme {
  String get displayName {
    switch (this) {
      case ColorTheme.catppuccinMocha:
        return 'Catppuccin Mocha';
      case ColorTheme.catppuccinLatte:
        return 'Catppuccin Latte';
      case ColorTheme.gruvboxDark:
        return 'Gruvbox Dark';
      case ColorTheme.gruvboxLight:
        return 'Gruvbox Light';
      case ColorTheme.solarizedDark:
        return 'Solarized Dark';
      case ColorTheme.solarizedLight:
        return 'Solarized Light';
      case ColorTheme.dracula:
        return 'Dracula';
      case ColorTheme.nord:
        return 'Nord';
      case ColorTheme.oneDark:
        return 'One Dark';
      case ColorTheme.tokyoNight:
        return 'Tokyo Night';
      case ColorTheme.rosePine:
        return 'Rose Pine';
      case ColorTheme.kanagawa:
        return 'Kanagawa';
    }
  }

  bool get isDark {
    switch (this) {
      case ColorTheme.catppuccinLatte:
      case ColorTheme.gruvboxLight:
      case ColorTheme.solarizedLight:
        return false;
      default:
        return true;
    }
  }
}

class UserSettings {
  final bool privacyMode;
  final bool analyticsEnabled;
  final bool onboardingCompleted;
  final DateTime? lastCompletionDate;
  final bool appLockEnabled;
  final AppLockType appLockType;
  final String? pinHash;
  final ThemeModePreference themeMode;
  final ColorTheme colorTheme;
  final GuidedModeType guidedModeType;
  final bool aiConsentEnabled;
  final TitleBarStyle titleBarStyle;
  final String? reminderSettingsJson;
  final Set<HomeAnalyticsWidget> homeAnalyticsWidgets;
  final CardGlowIntensity cardGlowIntensity;
  final BackgroundPattern backgroundPattern;
  final PageTransitionStyle pageTransitionStyle;

  const UserSettings({
    this.privacyMode = false,
    this.analyticsEnabled = false,
    this.onboardingCompleted = false,
    this.lastCompletionDate,
    this.appLockEnabled = false,
    this.appLockType = AppLockType.none,
    this.pinHash,
    this.themeMode = ThemeModePreference.system,
    this.colorTheme = ColorTheme.catppuccinMocha,
    this.guidedModeType = GuidedModeType.keyword,
    this.aiConsentEnabled = false,
    this.titleBarStyle = TitleBarStyle.minimal,
    this.reminderSettingsJson,
    this.homeAnalyticsWidgets = const {HomeAnalyticsWidget.wordCloud},
    this.cardGlowIntensity = CardGlowIntensity.none,
    this.backgroundPattern = BackgroundPattern.none,
    this.pageTransitionStyle = PageTransitionStyle.fade,
  });

  // Helper getters for backwards compatibility and convenience
  bool get guidedModeEnabled => guidedModeType != GuidedModeType.off;

  UserSettings copyWith({
    bool? privacyMode,
    bool? analyticsEnabled,
    bool? onboardingCompleted,
    DateTime? lastCompletionDate,
    bool? appLockEnabled,
    AppLockType? appLockType,
    String? pinHash,
    ThemeModePreference? themeMode,
    ColorTheme? colorTheme,
    GuidedModeType? guidedModeType,
    bool? aiConsentEnabled,
    TitleBarStyle? titleBarStyle,
    String? reminderSettingsJson,
    Set<HomeAnalyticsWidget>? homeAnalyticsWidgets,
    CardGlowIntensity? cardGlowIntensity,
    BackgroundPattern? backgroundPattern,
    PageTransitionStyle? pageTransitionStyle,
  }) {
    return UserSettings(
      privacyMode: privacyMode ?? this.privacyMode,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockType: appLockType ?? this.appLockType,
      pinHash: pinHash ?? this.pinHash,
      themeMode: themeMode ?? this.themeMode,
      colorTheme: colorTheme ?? this.colorTheme,
      guidedModeType: guidedModeType ?? this.guidedModeType,
      aiConsentEnabled: aiConsentEnabled ?? this.aiConsentEnabled,
      titleBarStyle: titleBarStyle ?? this.titleBarStyle,
      reminderSettingsJson: reminderSettingsJson ?? this.reminderSettingsJson,
      homeAnalyticsWidgets: homeAnalyticsWidgets ?? this.homeAnalyticsWidgets,
      cardGlowIntensity: cardGlowIntensity ?? this.cardGlowIntensity,
      backgroundPattern: backgroundPattern ?? this.backgroundPattern,
      pageTransitionStyle: pageTransitionStyle ?? this.pageTransitionStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'privacyMode': privacyMode,
      'analyticsEnabled': analyticsEnabled,
      'onboardingCompleted': onboardingCompleted,
      'lastCompletionDate': lastCompletionDate?.toIso8601String(),
      'appLockEnabled': appLockEnabled,
      'appLockType': appLockType.index,
      'pinHash': pinHash,
      'themeMode': themeMode.index,
      'colorTheme': colorTheme.index,
      'guidedModeType': guidedModeType.index,
      'aiConsentEnabled': aiConsentEnabled,
      'titleBarStyle': titleBarStyle.index,
      'reminderSettingsJson': reminderSettingsJson,
      'homeAnalyticsWidgets': homeAnalyticsWidgets.map((w) => w.index).toList(),
      'cardGlowIntensity': cardGlowIntensity.index,
      'backgroundPattern': backgroundPattern.index,
      'pageTransitionStyle': pageTransitionStyle.index,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    // Handle backwards compatibility for guidedModeType
    GuidedModeType guidedModeType;
    if (json.containsKey('guidedModeType')) {
      guidedModeType = GuidedModeType.values[json['guidedModeType'] as int? ?? 1];
    } else if (json.containsKey('guidedModeEnabled')) {
      // Migrate from old boolean format
      final enabled = json['guidedModeEnabled'] as bool? ?? true;
      guidedModeType = enabled ? GuidedModeType.keyword : GuidedModeType.off;
    } else {
      guidedModeType = GuidedModeType.keyword;
    }

    // Parse homeAnalyticsWidgets with default to word cloud only
    Set<HomeAnalyticsWidget> homeAnalyticsWidgets;
    if (json.containsKey('homeAnalyticsWidgets')) {
      final widgetsList = json['homeAnalyticsWidgets'] as List<dynamic>?;
      if (widgetsList != null && widgetsList.isNotEmpty) {
        homeAnalyticsWidgets = widgetsList
            .map((i) => HomeAnalyticsWidget.values[i as int])
            .toSet();
      } else {
        homeAnalyticsWidgets = {HomeAnalyticsWidget.wordCloud};
      }
    } else {
      homeAnalyticsWidgets = {HomeAnalyticsWidget.wordCloud};
    }

    return UserSettings(
      privacyMode: json['privacyMode'] as bool? ?? false,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      lastCompletionDate: json['lastCompletionDate'] != null
          ? DateTime.parse(json['lastCompletionDate'] as String)
          : null,
      appLockEnabled: json['appLockEnabled'] as bool? ?? false,
      appLockType: AppLockType.values[json['appLockType'] as int? ?? 0],
      pinHash: json['pinHash'] as String?,
      themeMode: ThemeModePreference.values[json['themeMode'] as int? ?? 0],
      colorTheme: ColorTheme.values[json['colorTheme'] as int? ?? 0],
      guidedModeType: guidedModeType,
      aiConsentEnabled: json['aiConsentEnabled'] as bool? ?? false,
      titleBarStyle: TitleBarStyle.values[json['titleBarStyle'] as int? ?? 1],
      reminderSettingsJson: json['reminderSettingsJson'] as String?,
      homeAnalyticsWidgets: homeAnalyticsWidgets,
      cardGlowIntensity: CardGlowIntensity.values[json['cardGlowIntensity'] as int? ?? 0],
      backgroundPattern: BackgroundPattern.values[json['backgroundPattern'] as int? ?? 0],
      pageTransitionStyle: PageTransitionStyle.values[json['pageTransitionStyle'] as int? ?? 1], // Default to fade
    );
  }
}
