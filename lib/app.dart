import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'data/models/user_settings.dart';
import 'domain/services/shortcut_service.dart';
import 'presentation/providers/providers.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/widgets/custom_title_bar.dart';
import 'presentation/widgets/keyboard_shortcuts_overlay.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    // Determine the effective theme mode
    ThemeMode themeMode;
    switch (settings.themeMode) {
      case ThemeModePreference.system:
        themeMode = ThemeMode.system;
      case ThemeModePreference.light:
        themeMode = ThemeMode.light;
      case ThemeModePreference.dark:
        themeMode = ThemeMode.dark;
    }

    final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    Widget app = MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.getTheme(settings.colorTheme, Brightness.light),
      darkTheme: AppTheme.getTheme(settings.colorTheme, Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Only show custom title bar on desktop with minimal style
        if (!CustomTitleBar.isDesktop || settings.titleBarStyle != TitleBarStyle.minimal) {
          return child ?? const SizedBox.shrink();
        }
        return Column(
          children: [
            const CustomTitleBar(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );

    // Wrap with keyboard shortcuts on desktop
    if (isDesktop) {
      final shortcutService = ref.watch(shortcutServiceProvider);
      app = Shortcuts(
        shortcuts: shortcutService.buildShortcuts(),
        child: Actions(
          actions: <Type, Action<Intent>>{
            NewEntryIntent: CallbackAction<NewEntryIntent>(
              onInvoke: (_) => router.go('/category-selection'),
            ),
            GoHomeIntent: CallbackAction<GoHomeIntent>(
              onInvoke: (_) => router.go('/home'),
            ),
            GoHistoryIntent: CallbackAction<GoHistoryIntent>(
              onInvoke: (_) => router.go('/history'),
            ),
            OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
              onInvoke: (_) => router.go('/settings'),
            ),
            OpenGoalsIntent: CallbackAction<OpenGoalsIntent>(
              onInvoke: (_) => router.go('/goals'),
            ),
            OpenAnalyticsIntent: CallbackAction<OpenAnalyticsIntent>(
              onInvoke: (_) => router.go('/analytics'),
            ),
            ShowHelpIntent: CallbackAction<ShowHelpIntent>(
              onInvoke: (_) {
                final context = router.routerDelegate.navigatorKey.currentContext;
                if (context != null) {
                  KeyboardShortcutsOverlay.show(context);
                }
                return null;
              },
            ),
            GoBackIntent: CallbackAction<GoBackIntent>(
              onInvoke: (_) {
                final context = router.routerDelegate.navigatorKey.currentContext;
                if (context != null && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                return null;
              },
            ),
          },
          child: app,
        ),
      );
    }

    return PlatformMenuBar(
      menus: const <PlatformMenuItem>[],
      child: app,
    );
  }
}
