import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'data/models/user_settings.dart';
import 'presentation/providers/providers.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/widgets/custom_title_bar.dart';

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

    return PlatformMenuBar(
      menus: const <PlatformMenuItem>[],
      child: MaterialApp.router(
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
      ),
    );
  }
}
