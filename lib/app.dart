import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'data/models/reminder_settings.dart';
import 'data/models/user_settings.dart';
import 'domain/services/shortcut_service.dart';
import 'presentation/providers/providers.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/widgets/custom_title_bar.dart';
import 'presentation/widgets/keyboard_shortcuts_overlay.dart';
import 'presentation/widgets/patterned_background.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rescheduleRemindersIfNeeded();
    }
  }

  Future<void> _rescheduleRemindersIfNeeded() async {
    final settings = ref.read(settingsProvider);
    final json = settings.reminderSettingsJson;
    if (json == null) return;

    try {
      final reminderSettings = ReminderSettings.fromJson(json);
      if (!reminderSettings.enabled) return;

      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.scheduleReminders(reminderSettings);
    } catch (_) {
      // Ignore invalid reminder settings payload.
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final hasPattern = settings.backgroundPattern != BackgroundPattern.none;

    // Get base themes
    var lightTheme = AppTheme.getTheme(settings.colorTheme, Brightness.light);
    var darkTheme = AppTheme.getTheme(settings.colorTheme, Brightness.dark);

    // Build page transitions based on user preference
    PageTransitionsTheme? transitionsTheme;
    if (settings.pageTransitionStyle != PageTransitionStyle.none) {
      final PageTransitionsBuilder builder;
      if (hasPattern) {
        // When pattern is active, use crossfade variants to avoid layered pages
        builder = settings.pageTransitionStyle == PageTransitionStyle.slide
            ? const _CrossfadeSlidePageTransitionsBuilder()
            : const _CrossfadePageTransitionsBuilder();
      } else {
        // No pattern, can use standard transitions
        builder = settings.pageTransitionStyle == PageTransitionStyle.slide
            ? const _SlidePageTransitionsBuilder()
            : const _CrossfadePageTransitionsBuilder();
      }
      transitionsTheme = PageTransitionsTheme(
        builders: {
          TargetPlatform.android: builder,
          TargetPlatform.iOS: builder,
          TargetPlatform.linux: builder,
          TargetPlatform.macOS: builder,
          TargetPlatform.windows: builder,
        },
      );
    }

    // Apply transparent scaffolds and transitions
    if (hasPattern) {
      lightTheme = lightTheme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        pageTransitionsTheme: transitionsTheme,
      );
      darkTheme = darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        pageTransitionsTheme: transitionsTheme,
      );
    } else if (transitionsTheme != null) {
      lightTheme = lightTheme.copyWith(pageTransitionsTheme: transitionsTheme);
      darkTheme = darkTheme.copyWith(pageTransitionsTheme: transitionsTheme);
    }

    Widget app = MaterialApp.router(
      title: AppConstants.appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Wrap with patterned background
        Widget content = PatternedBackground(
          child: child ?? const SizedBox.shrink(),
        );

        // Only show custom title bar on desktop with minimal style
        if (!CustomTitleBar.isDesktop || settings.titleBarStyle != TitleBarStyle.minimal) {
          return content;
        }
        return Column(
          children: [
            const CustomTitleBar(),
            Expanded(child: content),
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

/// A page transition that crossfades between pages (old fades out, new fades in).
class _CrossfadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CrossfadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: FadeTransition(
        // Fade out when this page is being covered by another
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(secondaryAnimation),
        child: child,
      ),
    );
  }
}

/// A page transition that slides pages in/out horizontally.
class _SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _SlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // New page slides in from right
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    // Old page slides out to left
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    ));

    return SlideTransition(
      position: slideOut,
      child: SlideTransition(
        position: slideIn,
        child: child,
      ),
    );
  }
}

/// A slide transition that also fades to work with transparent scaffolds.
class _CrossfadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CrossfadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // New page slides in from right and fades in
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    // Old page slides out to left and fades out
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    ));

    return SlideTransition(
      position: slideOut,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(secondaryAnimation),
        child: SlideTransition(
          position: slideIn,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
    );
  }
}
