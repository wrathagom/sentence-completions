import 'package:flutter_test/flutter_test.dart';
import 'package:sentence_completion/data/models/keyboard_shortcut.dart';
import 'package:sentence_completion/domain/services/shortcut_service.dart';

void main() {
  group('ShortcutService', () {
    late ShortcutService service;

    setUp(() {
      service = ShortcutService();
    });

    test('buildShortcuts returns non-empty map', () {
      final shortcuts = service.buildShortcuts();
      expect(shortcuts, isNotEmpty);
    });

    test('getAllShortcuts returns all defined shortcuts', () {
      final shortcuts = service.getAllShortcuts();
      expect(shortcuts.length, greaterThan(0));
      expect(shortcuts.length, equals(AppKeyboardShortcuts.shortcuts.length));
    });

    test('getShortcutsByCategory returns categorized shortcuts', () {
      final categories = service.getShortcutsByCategory();

      expect(categories, isNotEmpty);
      expect(categories.containsKey('Navigation'), isTrue);
      expect(categories.containsKey('Entries'), isTrue);
      expect(categories.containsKey('Other'), isTrue);
    });

    test('all shortcuts in categories are valid', () {
      final categories = service.getShortcutsByCategory();

      for (final category in categories.entries) {
        for (final shortcut in category.value) {
          expect(shortcut.id, isNotEmpty);
          expect(shortcut.label, isNotEmpty);
          expect(shortcut.displayKey, isNotEmpty);
        }
      }
    });
  });

  group('AppKeyboardShortcuts', () {
    test('findById returns correct shortcut', () {
      final shortcut = AppKeyboardShortcuts.findById(ShortcutAction.newEntry);
      expect(shortcut, isNotNull);
      expect(shortcut!.id, equals(ShortcutAction.newEntry));
      expect(shortcut.label, equals('New Entry'));
    });

    test('findById returns null for unknown id', () {
      final shortcut = AppKeyboardShortcuts.findById('unknown_action');
      expect(shortcut, isNull);
    });

    test('all shortcuts have unique ids', () {
      final ids = AppKeyboardShortcuts.shortcuts.map((s) => s.id).toSet();
      expect(ids.length, equals(AppKeyboardShortcuts.shortcuts.length));
    });

    test('all shortcuts have display keys', () {
      for (final shortcut in AppKeyboardShortcuts.shortcuts) {
        expect(shortcut.displayKey, isNotEmpty);
      }
    });
  });

  group('ShortcutAction', () {
    test('all action constants are defined', () {
      expect(ShortcutAction.newEntry, isNotNull);
      expect(ShortcutAction.saveEntry, isNotNull);
      expect(ShortcutAction.goHome, isNotNull);
      expect(ShortcutAction.goHistory, isNotNull);
      expect(ShortcutAction.openSettings, isNotNull);
      expect(ShortcutAction.focusSearch, isNotNull);
      expect(ShortcutAction.toggleFavorite, isNotNull);
      expect(ShortcutAction.refreshStem, isNotNull);
      expect(ShortcutAction.showHelp, isNotNull);
      expect(ShortcutAction.goBack, isNotNull);
    });
  });

  group('Intent classes', () {
    test('all intents can be instantiated', () {
      expect(const NewEntryIntent(), isA<NewEntryIntent>());
      expect(const SaveEntryIntent(), isA<SaveEntryIntent>());
      expect(const GoHomeIntent(), isA<GoHomeIntent>());
      expect(const GoHistoryIntent(), isA<GoHistoryIntent>());
      expect(const OpenSettingsIntent(), isA<OpenSettingsIntent>());
      expect(const FocusSearchIntent(), isA<FocusSearchIntent>());
      expect(const ToggleFavoriteIntent(), isA<ToggleFavoriteIntent>());
      expect(const RefreshStemIntent(), isA<RefreshStemIntent>());
      expect(const ShowHelpIntent(), isA<ShowHelpIntent>());
      expect(const GoBackIntent(), isA<GoBackIntent>());
    });
  });
}
