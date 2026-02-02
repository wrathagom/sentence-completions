import 'package:flutter/material.dart';

/// Visual style for share cards
enum ShareCardStyle {
  minimal('minimal', 'Minimal', Colors.white, Colors.black87),
  dark('dark', 'Dark', Color(0xFF1A1A2E), Colors.white),
  gradient('gradient', 'Gradient', Color(0xFF667EEA), Colors.white),
  nature('nature', 'Nature', Color(0xFF2D5A27), Colors.white),
  sunset('sunset', 'Sunset', Color(0xFFFF6B6B), Colors.white),
  ocean('ocean', 'Ocean', Color(0xFF0077B6), Colors.white);

  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ShareCardStyle(this.value, this.label, this.backgroundColor, this.textColor);

  /// Secondary gradient color for gradient-style cards
  Color? get gradientEndColor {
    switch (this) {
      case ShareCardStyle.gradient:
        return const Color(0xFF764BA2);
      case ShareCardStyle.nature:
        return const Color(0xFF5D9654);
      case ShareCardStyle.sunset:
        return const Color(0xFFFECA57);
      case ShareCardStyle.ocean:
        return const Color(0xFF00B4D8);
      default:
        return null;
    }
  }

  bool get hasGradient => gradientEndColor != null;

  static ShareCardStyle fromValue(String value) {
    return ShareCardStyle.values.firstWhere(
      (style) => style.value == value,
      orElse: () => ShareCardStyle.minimal,
    );
  }
}

/// Options for generating a share card
class ShareCardOptions {
  final ShareCardStyle style;
  final bool showCategory;
  final bool showDate;
  final bool showAppBranding;
  final double fontSize;

  const ShareCardOptions({
    this.style = ShareCardStyle.minimal,
    this.showCategory = true,
    this.showDate = true,
    this.showAppBranding = true,
    this.fontSize = 24.0,
  });

  ShareCardOptions copyWith({
    ShareCardStyle? style,
    bool? showCategory,
    bool? showDate,
    bool? showAppBranding,
    double? fontSize,
  }) {
    return ShareCardOptions(
      style: style ?? this.style,
      showCategory: showCategory ?? this.showCategory,
      showDate: showDate ?? this.showDate,
      showAppBranding: showAppBranding ?? this.showAppBranding,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

/// Result of share card generation
class ShareCardResult {
  final String? filePath;
  final String? error;
  final bool success;

  const ShareCardResult({
    this.filePath,
    this.error,
    required this.success,
  });

  factory ShareCardResult.success(String filePath) {
    return ShareCardResult(
      filePath: filePath,
      success: true,
    );
  }

  factory ShareCardResult.failure(String error) {
    return ShareCardResult(
      error: error,
      success: false,
    );
  }
}
