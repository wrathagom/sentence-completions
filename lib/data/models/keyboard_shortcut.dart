import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a keyboard shortcut action
class KeyboardShortcut {
  final String id;
  final String label;
  final String description;
  final LogicalKeySet keySet;
  final String displayKey;

  const KeyboardShortcut({
    required this.id,
    required this.label,
    required this.description,
    required this.keySet,
    required this.displayKey,
  });
}

/// Constants for keyboard shortcut actions
class ShortcutAction {
  static const String newEntry = 'new_entry';
  static const String saveEntry = 'save_entry';
  static const String goHome = 'go_home';
  static const String goHistory = 'go_history';
  static const String openSettings = 'open_settings';
  static const String focusSearch = 'focus_search';
  static const String toggleFavorite = 'toggle_favorite';
  static const String refreshStem = 'refresh_stem';
  static const String showHelp = 'show_help';
  static const String goBack = 'go_back';
  static const String openGoals = 'open_goals';
  static const String openAnalytics = 'open_analytics';
}

/// All available keyboard shortcuts
class AppKeyboardShortcuts {
  static final List<KeyboardShortcut> shortcuts = [
    KeyboardShortcut(
      id: ShortcutAction.newEntry,
      label: 'New Entry',
      description: 'Start a new journal entry',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN),
      displayKey: 'Ctrl+N',
    ),
    KeyboardShortcut(
      id: ShortcutAction.saveEntry,
      label: 'Save Entry',
      description: 'Save the current entry',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS),
      displayKey: 'Ctrl+S',
    ),
    KeyboardShortcut(
      id: ShortcutAction.goHome,
      label: 'Go Home',
      description: 'Navigate to home screen',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH),
      displayKey: 'Ctrl+H',
    ),
    KeyboardShortcut(
      id: ShortcutAction.goHistory,
      label: 'Go to History',
      description: 'Navigate to history/journal',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyJ),
      displayKey: 'Ctrl+J',
    ),
    KeyboardShortcut(
      id: ShortcutAction.openSettings,
      label: 'Settings',
      description: 'Open settings',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.comma),
      displayKey: 'Ctrl+,',
    ),
    KeyboardShortcut(
      id: ShortcutAction.focusSearch,
      label: 'Focus Search',
      description: 'Focus the search field',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF),
      displayKey: 'Ctrl+F',
    ),
    KeyboardShortcut(
      id: ShortcutAction.toggleFavorite,
      label: 'Toggle Favorite',
      description: 'Mark/unmark entry as favorite',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD),
      displayKey: 'Ctrl+D',
    ),
    KeyboardShortcut(
      id: ShortcutAction.refreshStem,
      label: 'Refresh/Next Stem',
      description: 'Get a new sentence stem',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR),
      displayKey: 'Ctrl+R',
    ),
    KeyboardShortcut(
      id: ShortcutAction.openGoals,
      label: 'Open Goals',
      description: 'Navigate to goals screen',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyG),
      displayKey: 'Ctrl+G',
    ),
    KeyboardShortcut(
      id: ShortcutAction.openAnalytics,
      label: 'Open Analytics',
      description: 'Navigate to analytics screen',
      keySet: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA),
      displayKey: 'Ctrl+A',
    ),
    KeyboardShortcut(
      id: ShortcutAction.showHelp,
      label: 'Show Shortcuts',
      description: 'Display keyboard shortcuts help',
      keySet: LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.slash),
      displayKey: '?',
    ),
    KeyboardShortcut(
      id: ShortcutAction.goBack,
      label: 'Close/Back',
      description: 'Close dialog or go back',
      keySet: LogicalKeySet(LogicalKeyboardKey.escape),
      displayKey: 'Esc',
    ),
  ];

  static KeyboardShortcut? findById(String id) {
    try {
      return shortcuts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
