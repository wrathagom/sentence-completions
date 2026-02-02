import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/keyboard_shortcut.dart';

/// Intent classes for keyboard shortcuts
class NewEntryIntent extends Intent {
  const NewEntryIntent();
}

class SaveEntryIntent extends Intent {
  const SaveEntryIntent();
}

class GoHomeIntent extends Intent {
  const GoHomeIntent();
}

class GoHistoryIntent extends Intent {
  const GoHistoryIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class ToggleFavoriteIntent extends Intent {
  const ToggleFavoriteIntent();
}

class RefreshStemIntent extends Intent {
  const RefreshStemIntent();
}

class ShowHelpIntent extends Intent {
  const ShowHelpIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}

class OpenGoalsIntent extends Intent {
  const OpenGoalsIntent();
}

class OpenAnalyticsIntent extends Intent {
  const OpenAnalyticsIntent();
}

/// Service to manage keyboard shortcuts
class ShortcutService {
  /// Build the shortcuts map for the Shortcuts widget
  Map<LogicalKeySet, Intent> buildShortcuts() {
    return {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
          const NewEntryIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
          const SaveEntryIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH):
          const GoHomeIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyJ):
          const GoHistoryIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.comma):
          const OpenSettingsIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
          const FocusSearchIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
          const ToggleFavoriteIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
          const RefreshStemIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyG):
          const OpenGoalsIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
          const OpenAnalyticsIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.slash):
          const ShowHelpIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): const GoBackIntent(),
    };
  }

  /// Get all shortcuts for display
  List<KeyboardShortcut> getAllShortcuts() {
    return AppKeyboardShortcuts.shortcuts;
  }

  /// Group shortcuts by category for organized display
  Map<String, List<KeyboardShortcut>> getShortcutsByCategory() {
    return {
      'Navigation': [
        AppKeyboardShortcuts.findById(ShortcutAction.goHome)!,
        AppKeyboardShortcuts.findById(ShortcutAction.goHistory)!,
        AppKeyboardShortcuts.findById(ShortcutAction.openSettings)!,
        AppKeyboardShortcuts.findById(ShortcutAction.openGoals)!,
        AppKeyboardShortcuts.findById(ShortcutAction.openAnalytics)!,
        AppKeyboardShortcuts.findById(ShortcutAction.goBack)!,
      ],
      'Entries': [
        AppKeyboardShortcuts.findById(ShortcutAction.newEntry)!,
        AppKeyboardShortcuts.findById(ShortcutAction.saveEntry)!,
        AppKeyboardShortcuts.findById(ShortcutAction.toggleFavorite)!,
        AppKeyboardShortcuts.findById(ShortcutAction.refreshStem)!,
      ],
      'Other': [
        AppKeyboardShortcuts.findById(ShortcutAction.focusSearch)!,
        AppKeyboardShortcuts.findById(ShortcutAction.showHelp)!,
      ],
    };
  }
}
