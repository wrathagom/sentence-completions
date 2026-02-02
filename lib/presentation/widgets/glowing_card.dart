import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_settings.dart';
import '../providers/providers.dart';

/// A Card widget that applies a glow effect based on user settings.
class GlowingCard extends ConsumerWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor,
    this.margin,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final intensity = settings.cardGlowIntensity;

    if (intensity == CardGlowIntensity.none) {
      return Card(
        margin: margin,
        color: color,
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      );
    }

    final effectiveGlowColor = glowColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: margin ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: effectiveGlowColor.withOpacity(intensity.opacity),
            blurRadius: intensity.blurRadius,
            spreadRadius: intensity.blurRadius / 4,
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: color,
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
