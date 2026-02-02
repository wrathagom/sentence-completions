import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import 'package:window_manager/window_manager.dart' as wm;

import '../../../core/constants.dart';
import '../../../core/responsive.dart';
import '../../../data/models/user_settings.dart';
import '../../providers/providers.dart';
import '../../widgets/custom_title_bar.dart';
import 'widgets/guided_mode_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.maxContentWidth ?? double.infinity,
          ),
          child: ListView(
            children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.brightness_6,
                title: 'Theme Mode',
                subtitle: _getThemeModeLabel(settings.themeMode),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeModeDialog(context, ref, settings),
              ),
              _SettingsTile(
                icon: Icons.palette,
                title: 'Color Theme',
                subtitle: settings.colorTheme.displayName,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showColorThemeDialog(context, ref, settings),
              ),
              if (CustomTitleBar.isDesktop)
                _SettingsTile(
                  icon: Icons.title,
                  title: 'Title Bar',
                  subtitle: _getTitleBarStyleLabel(settings.titleBarStyle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTitleBarStyleDialog(context, ref, settings),
                ),
            ],
          ),
          _SettingsSection(
            title: 'Mode',
            children: [
              _SettingsTile(
                icon: settings.privacyMode ? Icons.lock : Icons.book,
                title: settings.privacyMode ? 'Private Mode' : 'Journal Mode',
                subtitle: settings.privacyMode
                    ? 'Entries are deleted after viewing'
                    : 'Entries are stored for review',
                trailing: TextButton(
                  onPressed: () => _showModeDialog(context, ref, settings),
                  child: const Text('Change'),
                ),
              ),
              _SettingsTile(
                icon: settings.guidedModeType != GuidedModeType.off
                    ? Icons.assistant
                    : Icons.assistant_outlined,
                title: 'Guided Mode',
                subtitle: settings.guidedModeType.description,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showGuidedModeDialog(context, ref, settings),
              ),
              if (settings.guidedModeType != GuidedModeType.off)
                _SettingsTile(
                  icon: Icons.bookmark_outline,
                  title: 'Saved Prompts',
                  subtitle: 'View and manage saved prompts',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/saved-stems'),
                ),
            ],
          ),
          _SettingsSection(
            title: 'Privacy & Security',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.analytics_outlined),
                title: const Text('Analytics'),
                subtitle: const Text('Help improve the app with anonymous data'),
                value: settings.analyticsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setAnalyticsEnabled(value);
                },
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'App Lock',
                subtitle: settings.appLockEnabled
                    ? _getLockTypeLabel(settings.appLockType)
                    : 'Disabled',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAppLockDialog(context, ref, settings),
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: AppConstants.appVersion,
              ),
            ],
          ),
          // Only show Quit on desktop platforms
          if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS))
            _SettingsSection(
              title: '',
              children: [
                _SettingsTile(
                  icon: Icons.exit_to_app,
                  title: 'Quit',
                  subtitle: 'Close the application',
                  onTap: () => _showQuitDialog(context),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuitDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit'),
        content: const Text('Are you sure you want to quit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      SystemNavigator.pop();
    }
  }

  String _getThemeModeLabel(ThemeModePreference mode) {
    switch (mode) {
      case ThemeModePreference.system:
        return 'System';
      case ThemeModePreference.light:
        return 'Light';
      case ThemeModePreference.dark:
        return 'Dark';
    }
  }

  String _getLockTypeLabel(AppLockType type) {
    switch (type) {
      case AppLockType.biometric:
        return 'Biometric';
      case AppLockType.pin:
        return 'PIN';
      case AppLockType.none:
        return 'Disabled';
    }
  }

  String _getTitleBarStyleLabel(TitleBarStyle style) {
    switch (style) {
      case TitleBarStyle.system:
        return 'System';
      case TitleBarStyle.minimal:
        return 'Minimal';
      case TitleBarStyle.none:
        return 'None';
    }
  }

  Future<void> _showTitleBarStyleDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final result = await showDialog<TitleBarStyle?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Title Bar Style'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(TitleBarStyle.minimal),
            child: ListTile(
              leading: const Icon(Icons.minimize),
              title: const Text('Minimal'),
              subtitle: const Text('Clean look with small window controls'),
              trailing: settings.titleBarStyle == TitleBarStyle.minimal
                  ? const Icon(Icons.check)
                  : null,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(TitleBarStyle.none),
            child: ListTile(
              leading: const Icon(Icons.close_fullscreen),
              title: const Text('None'),
              subtitle: const Text('No title bar (use Settings to quit)'),
              trailing: settings.titleBarStyle == TitleBarStyle.none
                  ? const Icon(Icons.check)
                  : null,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(TitleBarStyle.system),
            child: ListTile(
              leading: const Icon(Icons.desktop_windows),
              title: const Text('System'),
              subtitle: const Text('Native operating system title bar'),
              trailing: settings.titleBarStyle == TitleBarStyle.system
                  ? const Icon(Icons.check)
                  : null,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(settingsProvider.notifier).setTitleBarStyle(result);
      // Apply the change immediately
      if (result == TitleBarStyle.system) {
        await wm.windowManager.setTitleBarStyle(wm.TitleBarStyle.normal);
      } else {
        await wm.windowManager.setTitleBarStyle(wm.TitleBarStyle.hidden);
      }
    }
  }

  Future<void> _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final result = await showDialog<ThemeModePreference?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme Mode'),
        children: [
          for (final mode in ThemeModePreference.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(mode),
              child: ListTile(
                leading: Icon(_getThemeModeIcon(mode)),
                title: Text(_getThemeModeLabel(mode)),
                trailing: settings.themeMode == mode
                    ? const Icon(Icons.check)
                    : null,
              ),
            ),
        ],
      ),
    );

    if (result != null) {
      ref.read(settingsProvider.notifier).setThemeMode(result);
    }
  }

  IconData _getThemeModeIcon(ThemeModePreference mode) {
    switch (mode) {
      case ThemeModePreference.system:
        return Icons.brightness_auto;
      case ThemeModePreference.light:
        return Icons.light_mode;
      case ThemeModePreference.dark:
        return Icons.dark_mode;
    }
  }

  Future<void> _showColorThemeDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final result = await showModalBottomSheet<ColorTheme?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Color Theme',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: ColorTheme.values.length,
                itemBuilder: (context, index) {
                  final theme = ColorTheme.values[index];
                  return _ColorThemeTile(
                    theme: theme,
                    isSelected: settings.colorTheme == theme,
                    onTap: () => Navigator.of(context).pop(theme),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      ref.read(settingsProvider.notifier).setColorTheme(result);
    }
  }

  Future<void> _showModeDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Mode'),
        content: Text(
          settings.privacyMode
              ? 'Switch to Journal Mode? Your future entries will be saved for review and resurfacing.'
              : 'Switch to Private Mode? Your future entries will be deleted after viewing. Existing entries will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(settingsProvider.notifier).setPrivacyMode(!settings.privacyMode);
    }
  }

  Future<void> _showGuidedModeDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => GuidedModeDialog(
        currentMode: settings.guidedModeType,
      ),
    );
  }

  Future<void> _showAppLockDialog(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final localAuth = LocalAuthentication();
    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    final isDeviceSupported = await localAuth.isDeviceSupported();
    final hasBiometrics = canCheckBiometrics && isDeviceSupported;

    if (!context.mounted) return;

    final result = await showDialog<AppLockType?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('App Lock'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(AppLockType.none),
            child: ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Disabled'),
              trailing: settings.appLockType == AppLockType.none
                  ? const Icon(Icons.check)
                  : null,
            ),
          ),
          if (hasBiometrics)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(AppLockType.biometric),
              child: ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric'),
                trailing: settings.appLockType == AppLockType.biometric
                    ? const Icon(Icons.check)
                    : null,
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(AppLockType.pin),
            child: ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('PIN'),
              trailing: settings.appLockType == AppLockType.pin
                  ? const Icon(Icons.check)
                  : null,
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result == AppLockType.biometric) {
        // Verify biometric works
        try {
          final authenticated = await localAuth.authenticate(
            localizedReason: 'Verify your identity to enable biometric lock',
          );
          if (authenticated) {
            ref.read(settingsProvider.notifier).setAppLock(
                  enabled: true,
                  type: AppLockType.biometric,
                );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Biometric authentication failed: $e')),
            );
          }
        }
      } else if (result == AppLockType.pin) {
        if (context.mounted) {
          final pin = await _showPinSetupDialog(context);
          if (pin != null) {
            ref.read(settingsProvider.notifier).setAppLock(
                  enabled: true,
                  type: AppLockType.pin,
                  pinHash: pin, // In production, hash this
                );
          }
        }
      } else {
        ref.read(settingsProvider.notifier).setAppLock(
              enabled: false,
              type: AppLockType.none,
            );
      }
    }
  }

  Future<String?> _showPinSetupDialog(BuildContext context) async {
    String pin = '';
    String confirmPin = '';
    bool isConfirming = false;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isConfirming ? 'Confirm PIN' : 'Set PIN'),
          content: TextField(
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: isConfirming ? 'Re-enter PIN' : 'Enter 4-6 digit PIN',
            ),
            onChanged: (value) {
              if (isConfirming) {
                confirmPin = value;
              } else {
                pin = value;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!isConfirming) {
                  if (pin.length >= 4) {
                    setState(() => isConfirming = true);
                  }
                } else {
                  if (pin == confirmPin) {
                    Navigator.of(context).pop(pin);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PINs do not match')),
                    );
                    setState(() {
                      isConfirming = false;
                      pin = '';
                      confirmPin = '';
                    });
                  }
                }
              },
              child: Text(isConfirming ? 'Confirm' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _ColorThemeTile extends StatelessWidget {
  final ColorTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _ThemePreview(theme: theme),
      title: Text(theme.displayName),
      subtitle: Text(theme.isDark ? 'Dark theme' : 'Light theme'),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final ColorTheme theme;

  const _ThemePreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = _getPreviewColors(theme);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 6,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _PreviewColors _getPreviewColors(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.catppuccinMocha:
        return _PreviewColors(
          background: const Color(0xFF1E1E2E),
          surface: const Color(0xFF313244),
          primary: const Color(0xFFCBA6F7),
          secondary: const Color(0xFFF5C2E7),
        );
      case ColorTheme.catppuccinLatte:
        return _PreviewColors(
          background: const Color(0xFFEFF1F5),
          surface: const Color(0xFFE6E9EF),
          primary: const Color(0xFF8839EF),
          secondary: const Color(0xFFEA76CB),
        );
      case ColorTheme.gruvboxDark:
        return _PreviewColors(
          background: const Color(0xFF282828),
          surface: const Color(0xFF3C3836),
          primary: const Color(0xFFFE8019),
          secondary: const Color(0xFFB8BB26),
        );
      case ColorTheme.gruvboxLight:
        return _PreviewColors(
          background: const Color(0xFFFBF1C7),
          surface: const Color(0xFFEBDBB2),
          primary: const Color(0xFFD65D0E),
          secondary: const Color(0xFF79740E),
        );
      case ColorTheme.solarizedDark:
        return _PreviewColors(
          background: const Color(0xFF002B36),
          surface: const Color(0xFF073642),
          primary: const Color(0xFF268BD2),
          secondary: const Color(0xFF2AA198),
        );
      case ColorTheme.solarizedLight:
        return _PreviewColors(
          background: const Color(0xFFFDF6E3),
          surface: const Color(0xFFEEE8D5),
          primary: const Color(0xFF268BD2),
          secondary: const Color(0xFF2AA198),
        );
      case ColorTheme.dracula:
        return _PreviewColors(
          background: const Color(0xFF282A36),
          surface: const Color(0xFF44475A),
          primary: const Color(0xFFBD93F9),
          secondary: const Color(0xFFFF79C6),
        );
      case ColorTheme.nord:
        return _PreviewColors(
          background: const Color(0xFF2E3440),
          surface: const Color(0xFF3B4252),
          primary: const Color(0xFF88C0D0),
          secondary: const Color(0xFF81A1C1),
        );
      case ColorTheme.oneDark:
        return _PreviewColors(
          background: const Color(0xFF282C34),
          surface: const Color(0xFF21252B),
          primary: const Color(0xFF61AFEF),
          secondary: const Color(0xFFC678DD),
        );
      case ColorTheme.tokyoNight:
        return _PreviewColors(
          background: const Color(0xFF1A1B26),
          surface: const Color(0xFF24283B),
          primary: const Color(0xFF7AA2F7),
          secondary: const Color(0xFFBB9AF7),
        );
      case ColorTheme.rosePine:
        return _PreviewColors(
          background: const Color(0xFF191724),
          surface: const Color(0xFF1F1D2E),
          primary: const Color(0xFFEB6F92),
          secondary: const Color(0xFFC4A7E7),
        );
      case ColorTheme.kanagawa:
        return _PreviewColors(
          background: const Color(0xFF1F1F28),
          surface: const Color(0xFF2A2A37),
          primary: const Color(0xFF7E9CD8),
          secondary: const Color(0xFF957FB8),
        );
    }
  }
}

class _PreviewColors {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;

  const _PreviewColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
  });
}
