import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation extensions for safe navigation operations
extension SafeNavigation on BuildContext {
  /// Safely pops the current route. If there's nothing to pop,
  /// navigates to the home screen instead.
  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/home');
    }
  }
}
