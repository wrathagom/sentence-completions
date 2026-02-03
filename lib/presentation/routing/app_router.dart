import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_settings.dart';
import '../providers/providers.dart';
import '../screens/completion/completion_screen.dart';
import '../screens/completion/mood_check_screen.dart';
import '../screens/favorites/favorites_screen.dart';
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
import '../screens/analytics/analytics_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/goals/create_goal_screen.dart';
import '../screens/settings/export_screen.dart';
import '../screens/settings/reminder_settings_screen.dart';
import '../screens/settings/deleted_entries_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/shortcuts_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/history/share_card_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);
  final hasPattern = settings.backgroundPattern != BackgroundPattern.none;
  final transitionStyle = settings.pageTransitionStyle;
  final transitionDuration = transitionStyle == PageTransitionStyle.none
      ? Duration.zero
      : const Duration(milliseconds: 420);

  CustomTransitionPage<void> buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (transitionStyle == PageTransitionStyle.none) {
          return child;
        }

        final pushIn = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final pushOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        ));

        final popOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1.0, 0.0),
        ).animate(CurvedAnimation(
          parent: ReverseAnimation(animation),
          curve: Curves.easeOutCubic,
        ));

        final popIn = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ReverseAnimation(secondaryAnimation),
          curve: Curves.easeOutCubic,
        ));

        final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
        );

        if (hasPattern) {
          if (transitionStyle == PageTransitionStyle.slide) {
            final isExiting = animation.status == AnimationStatus.reverse;
            final isCovering = secondaryAnimation.status == AnimationStatus.forward;
            final isRevealing =
                secondaryAnimation.status == AnimationStatus.reverse;

            if (isExiting) {
              return SlideTransition(
                position: popOut,
                child: child,
              );
            }

            if (isCovering) {
              return SlideTransition(
                position: pushOut,
                child: child,
              );
            }

            if (isRevealing) {
              return SlideTransition(
                position: popIn,
                child: child,
              );
            }

            if (animation.status == AnimationStatus.forward) {
              return SlideTransition(
                position: pushIn,
                child: child,
              );
            }

            return child;
          }

          final isOutgoing =
              secondaryAnimation.status != AnimationStatus.dismissed;
          if (isOutgoing) {
            return FadeTransition(
              opacity: fadeOut,
              child: child,
            );
          }
          return FadeTransition(
            opacity: fadeIn,
            child: child,
          );
        }

        if (transitionStyle == PageTransitionStyle.slide) {
          final isExiting = animation.status == AnimationStatus.reverse;
          final isCovering = secondaryAnimation.status == AnimationStatus.forward;
          final isRevealing = secondaryAnimation.status == AnimationStatus.reverse;

          if (isExiting) {
            return SlideTransition(
              position: popOut,
              child: child,
            );
          }

          if (isCovering) {
            return SlideTransition(
              position: pushOut,
              child: child,
            );
          }

          if (isRevealing) {
            return SlideTransition(
              position: popIn,
              child: child,
            );
          }

          if (animation.status == AnimationStatus.forward) {
            return SlideTransition(
              position: pushIn,
              child: child,
            );
          }

          return child;
        }

        return FadeTransition(
          opacity: fadeIn,
          child: child,
        );
      },
    );
  }

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
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const OnboardingWelcomeScreen()),
      ),
      GoRoute(
        path: '/onboarding/mode',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const OnboardingModeScreen()),
      ),
      GoRoute(
        path: '/onboarding/analytics',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const OnboardingAnalyticsScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const HomeScreen()),
      ),
      GoRoute(
        path: '/category-selection',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const CategorySelectionScreen()),
      ),
      GoRoute(
        path: '/completion',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return buildPage(
            state: state,
            child: CompletionScreen(
              stemId: extra?['stemId'] as String?,
              categoryId: extra?['categoryId'] as String?,
              stemText: extra?['stemText'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const HistoryScreen()),
      ),
      GoRoute(
        path: '/entry/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPage(
            state: state,
            child: EntryDetailScreen(entryId: id),
          );
        },
      ),
      GoRoute(
        path: '/post-completion/:entryId',
        pageBuilder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return buildPage(
            state: state,
            child: PostCompletionScreen(entryId: entryId),
          );
        },
      ),
      GoRoute(
        path: '/mood-check/:entryId',
        pageBuilder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return buildPage(
            state: state,
            child: MoodCheckScreen(entryId: entryId),
          );
        },
      ),
      GoRoute(
        path: '/favorites',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const FavoritesScreen()),
      ),
      GoRoute(
        path: '/saved-stems',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const SavedStemsScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const SettingsScreen()),
      ),
      GoRoute(
        path: '/export',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const ExportScreen()),
      ),
      GoRoute(
        path: '/analytics',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const AnalyticsScreen()),
      ),
      GoRoute(
        path: '/goals',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const GoalsScreen()),
      ),
      GoRoute(
        path: '/goals/create',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const CreateGoalScreen()),
      ),
      GoRoute(
        path: '/settings/reminders',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const ReminderSettingsScreen()),
      ),
      GoRoute(
        path: '/stats',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/resurfacing',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return buildPage(
            state: state,
            child: ResurfacingScreen(
              resurfacingEntry: extra['resurfacingEntry'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/comparison/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildPage(
            state: state,
            child: EntryDetailScreen(
              entryId: id,
              showComparison: true,
            ),
          );
        },
      ),
      GoRoute(
        path: '/share/:entryId',
        pageBuilder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return buildPage(
            state: state,
            child: ShareCardScreen(entryId: entryId),
          );
        },
      ),
      GoRoute(
        path: '/deleted',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const DeletedEntriesScreen()),
      ),
      GoRoute(
        path: '/settings/shortcuts',
        pageBuilder: (context, state) =>
            buildPage(state: state, child: const ShortcutsScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
