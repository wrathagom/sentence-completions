class AppConstants {
  static const String appName = 'Sentence Completion';
  static const String appVersion = '1.0.0';

  // Remote stems URL (set to null to use bundled only)
  static const String? stemsRemoteUrl = null;

  // Resurfacing intervals in months
  static const int firstResurfaceMonths = 3;
  static const int secondResurfaceMonths = 6;
}

class RouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String onboardingWelcome = 'welcome';
  static const String onboardingMode = 'mode';
  static const String onboardingAnalytics = 'analytics';
  static const String home = 'home';
  static const String categorySelection = 'categorySelection';
  static const String completion = 'completion';
  static const String history = 'history';
  static const String entryDetail = 'entryDetail';
  static const String settings = 'settings';
  static const String resurfacing = 'resurfacing';
  static const String comparison = 'comparison';
  static const String appLock = 'appLock';
}

class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingWelcome = 'welcome';
  static const String onboardingMode = 'mode';
  static const String onboardingAnalytics = 'analytics';
  static const String home = '/home';
  static const String categorySelection = '/category-selection';
  static const String completion = '/completion';
  static const String history = '/history';
  static const String entryDetail = '/entry/:id';
  static const String settings = '/settings';
  static const String resurfacing = '/resurfacing';
  static const String comparison = '/comparison/:id';
  static const String appLock = '/lock';
}
