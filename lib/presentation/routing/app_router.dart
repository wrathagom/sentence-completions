import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../screens/completion/completion_screen.dart';
import '../screens/completion/post_completion_screen.dart';
import '../screens/completion/resurfacing_screen.dart';
import '../screens/saved_stems/saved_stems_screen.dart';
import '../screens/history/entry_detail_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/category_selection_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_analytics_screen.dart';
import '../screens/onboarding/onboarding_mode_screen.dart';
import '../screens/onboarding/onboarding_welcome_screen.dart';
import '../screens/settings/export_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isOnboarding = path.startsWith('/onboarding');
      final isSplash = path == '/';

      if (isSplash) {
        return null; // Let splash handle initial routing
      }

      // Read settings inside redirect to avoid router rebuild on settings change
      final settings = ref.read(settingsProvider);

      if (!settings.onboardingCompleted && !isOnboarding) {
        return '/onboarding/welcome';
      }

      if (settings.onboardingCompleted && isOnboarding) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/mode',
        builder: (context, state) => const OnboardingModeScreen(),
      ),
      GoRoute(
        path: '/onboarding/analytics',
        builder: (context, state) => const OnboardingAnalyticsScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/category-selection',
        builder: (context, state) => const CategorySelectionScreen(),
      ),
      GoRoute(
        path: '/completion',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CompletionScreen(
            stemId: extra?['stemId'] as String?,
            categoryId: extra?['categoryId'] as String?,
            stemText: extra?['stemText'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/entry/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EntryDetailScreen(entryId: id);
        },
      ),
      GoRoute(
        path: '/post-completion/:entryId',
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return PostCompletionScreen(entryId: entryId);
        },
      ),
      GoRoute(
        path: '/saved-stems',
        builder: (context, state) => const SavedStemsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/export',
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: '/stats',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/resurfacing',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResurfacingScreen(
            resurfacingEntry: extra['resurfacingEntry'],
          );
        },
      ),
      GoRoute(
        path: '/comparison/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EntryDetailScreen(
            entryId: id,
            showComparison: true,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
