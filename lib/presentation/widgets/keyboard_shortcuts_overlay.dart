import 'package:flutter/material.dart';
import '../../data/models/keyboard_shortcut.dart';
import '../../domain/services/shortcut_service.dart';

/// Overlay dialog showing all keyboard shortcuts
class KeyboardShortcutsOverlay extends StatelessWidget {
  const KeyboardShortcutsOverlay({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortcutService = ShortcutService();
    final categories = shortcutService.getShortcutsByCategory();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Keyboard Shortcuts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.entries.map((category) {
                    return _ShortcutCategory(
                      title: category.key,
                      shortcuts: category.value,
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Press Esc to close',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCategory extends StatelessWidget {
  final String title;
  final List<KeyboardShortcut> shortcuts;

  const _ShortcutCategory({
    required this.title,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...shortcuts.map((shortcut) => _ShortcutRow(shortcut: shortcut)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final KeyboardShortcut shortcut;

  const _ShortcutRow({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              shortcut.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          _ShortcutKey(shortcut.displayKey),
        ],
      ),
    );
  }
}

class _ShortcutKey extends StatelessWidget {
  final String keyLabel;

  const _ShortcutKey(this.keyLabel);

  @override
  Widget build(BuildContext context) {
    // Split into individual keys if contains +
    final keys = keyLabel.split('+');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: keys.asMap().entries.map((entry) {
        final index = entry.key;
        final key = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
              ),
              child: Text(
                key,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (index < keys.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '+',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
