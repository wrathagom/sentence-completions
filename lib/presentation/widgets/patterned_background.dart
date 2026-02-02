import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_settings.dart';
import '../providers/providers.dart';

/// A widget that renders a subtle background pattern based on user settings.
class PatternedBackground extends ConsumerWidget {
  final Widget child;

  const PatternedBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final pattern = settings.backgroundPattern;

    if (pattern == BackgroundPattern.none) {
      return child;
    }

    // Get the background color from appBarTheme since scaffoldBackgroundColor
    // may be transparent (to allow pattern to show through)
    final backgroundColor = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          // Pattern drawn on top of background color
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(
                pattern: pattern,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content on top of pattern (scaffolds will be transparent)
          child,
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final BackgroundPattern pattern;
  final Color color;

  _PatternPainter({
    required this.pattern,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (pattern) {
      case BackgroundPattern.none:
        break;
      case BackgroundPattern.noise:
        _paintNoise(canvas, size, paint);
        break;
      case BackgroundPattern.dots:
        _paintDots(canvas, size, paint);
        break;
      case BackgroundPattern.diagonalLines:
        _paintDiagonalLines(canvas, size, paint);
        break;
    }
  }

  void _paintNoise(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fixed seed for consistent pattern
    final dotCount = (size.width * size.height / 100).toInt();

    for (var i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 16.0;
    const radius = 1.5;

    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _paintDiagonalLines(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    const spacing = 24.0;
    final diagonal = size.width + size.height;

    for (var i = -size.height; i < diagonal; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern || oldDelegate.color != color;
  }
}
