import '../datasources/local/settings_local_datasource.dart';
import '../models/user_settings.dart';

export '../models/user_settings.dart' show ThemeModePreference, ColorTheme;

class SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepository({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  UserSettings getSettings() {
    return _datasource.getSettings();
  }

  Future<void> saveSettings(UserSettings settings) {
    return _datasource.saveSettings(settings);
  }

  Future<void> setOnboardingCompleted(bool completed) {
    return _datasource.setOnboardingCompleted(completed);
  }

  Future<void> setPrivacyMode(bool enabled) {
    return _datasource.setPrivacyMode(enabled);
  }

  Future<void> setAnalyticsEnabled(bool enabled) {
    return _datasource.setAnalyticsEnabled(enabled);
  }

  Future<void> setLastCompletionDate(DateTime date) {
    return _datasource.setLastCompletionDate(date);
  }

  Future<void> setAppLock({
    required bool enabled,
    required AppLockType type,
    String? pinHash,
  }) {
    return _datasource.setAppLock(
      enabled: enabled,
      type: type,
      pinHash: pinHash,
    );
  }

  bool isOnboardingCompleted() {
    return getSettings().onboardingCompleted;
  }

  Future<void> setThemeMode(ThemeModePreference mode) {
    return _datasource.setThemeMode(mode);
  }

  Future<void> setColorTheme(ColorTheme theme) {
    return _datasource.setColorTheme(theme);
  }

  Future<void> setGuidedModeType(GuidedModeType type) {
    return _datasource.setGuidedModeType(type);
  }

  Future<void> setAiConsentEnabled(bool enabled) {
    return _datasource.setAiConsentEnabled(enabled);
  }

  Future<void> setTitleBarStyle(TitleBarStyle style) {
    return _datasource.setTitleBarStyle(style);
  }
}
