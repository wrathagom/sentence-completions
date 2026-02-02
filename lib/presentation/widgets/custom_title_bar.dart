import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// A minimal title bar for desktop platforms - just window controls and drag area.
class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  static bool get isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 32,
        color: Colors.transparent,
        child: Row(
          children: [
            // Drag area
            const Expanded(child: SizedBox.shrink()),
            _WindowButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
            ),
            _WindowButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 40,
          height: 32,
          color: _isHovered
              ? (widget.isClose
                  ? Colors.red
                  : colorScheme.onSurface.withValues(alpha: 0.1))
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 14,
            color: _isHovered && widget.isClose
                ? Colors.white
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
