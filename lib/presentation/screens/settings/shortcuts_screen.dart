import 'package:flutter/material.dart';
import '../../../core/navigation.dart';
import '../../../data/models/keyboard_shortcut.dart';
import '../../../domain/services/shortcut_service.dart';
import '../../widgets/responsive_scaffold.dart';

class ShortcutsScreen extends StatelessWidget {
  const ShortcutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcutService = ShortcutService();
    final categories = shortcutService.getShortcutsByCategory();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
        title: const Text('Keyboard Shortcuts'),
      ),
      body: ResponsiveCenter(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.keyboard,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Use keyboard shortcuts for faster navigation on desktop',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ...categories.entries.map((category) {
              return _ShortcutSection(
                title: category.key,
                shortcuts: category.value,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<KeyboardShortcut> shortcuts;

  const _ShortcutSection({
    required this.title,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          child: Column(
            children: shortcuts.asMap().entries.map((entry) {
              final index = entry.key;
              final shortcut = entry.value;
              return Column(
                children: [
                  _ShortcutTile(shortcut: shortcut),
                  if (index < shortcuts.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final KeyboardShortcut shortcut;

  const _ShortcutTile({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(shortcut.label),
      subtitle: Text(shortcut.description),
      trailing: _KeyChip(shortcut.displayKey),
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String keyLabel;

  const _KeyChip(this.keyLabel);

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withAlpha(77),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    offset: const Offset(0, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                key,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
