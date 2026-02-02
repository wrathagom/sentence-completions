import 'package:flutter/widgets.dart';

/// Breakpoint thresholds for responsive design
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Maximum content widths for different screen sizes
class ContentWidth {
  ContentWidth._();

  static const double tablet = 600;
  static const double desktop = 720;
}

/// Maximum button widths
class ButtonWidth {
  ButtonWidth._();

  static const double maxWidth = 400;
}

/// Determines the current screen size category
enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// Extension to get screen size from BuildContext
extension ResponsiveContext on BuildContext {
  /// Returns the current screen size category based on width
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < Breakpoints.mobile) {
      return ScreenSize.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  /// Returns true if screen is mobile-sized
  bool get isMobile => screenSize == ScreenSize.mobile;

  /// Returns true if screen is tablet-sized or larger
  bool get isTabletOrLarger => screenSize != ScreenSize.mobile;

  /// Returns true if screen is desktop-sized
  bool get isDesktop => screenSize == ScreenSize.desktop;

  /// Returns the appropriate max content width for current screen
  double? get maxContentWidth {
    switch (screenSize) {
      case ScreenSize.mobile:
        return null; // No constraint on mobile
      case ScreenSize.tablet:
        return ContentWidth.tablet;
      case ScreenSize.desktop:
        return ContentWidth.desktop;
    }
  }
}
