import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_settings.dart';

class SettingsLocalDatasource {
  static const String _settingsKey = 'user_settings';

  final SharedPreferences _prefs;

  SettingsLocalDatasource(this._prefs);

  UserSettings getSettings() {
    final json = _prefs.getString(_settingsKey);
    if (json == null) {
      return const UserSettings();
    }
    return UserSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(onboardingCompleted: completed));
  }

  Future<void> setPrivacyMode(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(privacyMode: enabled));
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(analyticsEnabled: enabled));
  }

  Future<void> setLastCompletionDate(DateTime date) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(lastCompletionDate: date));
  }

  Future<void> setAppLock({
    required bool enabled,
    required AppLockType type,
    String? pinHash,
  }) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      appLockEnabled: enabled,
      appLockType: type,
      pinHash: pinHash,
    ));
  }

  Future<void> setThemeMode(ThemeModePreference mode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  Future<void> setColorTheme(ColorTheme theme) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(colorTheme: theme));
  }

  Future<void> setGuidedModeType(GuidedModeType type) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(guidedModeType: type));
  }

  Future<void> setAiConsentEnabled(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(aiConsentEnabled: enabled));
  }

  Future<void> setTitleBarStyle(TitleBarStyle style) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(titleBarStyle: style));
  }

  Future<void> setReminderSettings(String? jsonSettings) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(reminderSettingsJson: jsonSettings));
  }
}
