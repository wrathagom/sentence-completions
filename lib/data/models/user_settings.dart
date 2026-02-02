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
    );
  }
}
