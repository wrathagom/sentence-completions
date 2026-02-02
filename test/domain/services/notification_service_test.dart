import 'package:flutter_test/flutter_test.dart';

import 'package:sentence_completion/data/models/reminder_settings.dart';

void main() {
  group('ReminderSettings', () {
    test('default settings have correct values', () {
      const settings = ReminderSettings();

      expect(settings.enabled, false);
      expect(settings.hour, 9);
      expect(settings.minute, 0);
      expect(settings.daysOfWeek, {1, 2, 3, 4, 5, 6, 7});
    });

    test('formattedTime returns correct AM time', () {
      const settings = ReminderSettings(hour: 9, minute: 30);
      expect(settings.formattedTime, '9:30 AM');
    });

    test('formattedTime returns correct PM time', () {
      const settings = ReminderSettings(hour: 14, minute: 0);
      expect(settings.formattedTime, '2:00 PM');
    });

    test('formattedTime handles noon correctly', () {
      const settings = ReminderSettings(hour: 12, minute: 0);
      expect(settings.formattedTime, '12:00 PM');
    });

    test('formattedTime handles midnight correctly', () {
      const settings = ReminderSettings(hour: 0, minute: 0);
      expect(settings.formattedTime, '12:00 AM');
    });

    test('daysDescription returns "Every day" for all days', () {
      const settings = ReminderSettings(
        daysOfWeek: {1, 2, 3, 4, 5, 6, 7},
      );
      expect(settings.daysDescription, 'Every day');
    });

    test('daysDescription returns "Weekdays" for weekdays only', () {
      const settings = ReminderSettings(
        daysOfWeek: {1, 2, 3, 4, 5},
      );
      expect(settings.daysDescription, 'Weekdays');
    });

    test('daysDescription returns "Weekends" for weekends only', () {
      const settings = ReminderSettings(
        daysOfWeek: {6, 7},
      );
      expect(settings.daysDescription, 'Weekends');
    });

    test('daysDescription lists individual days', () {
      const settings = ReminderSettings(
        daysOfWeek: {1, 3, 5},
      );
      expect(settings.daysDescription, 'Mon, Wed, Fri');
    });

    test('copyWith creates new instance with updated values', () {
      const original = ReminderSettings();
      final updated = original.copyWith(
        enabled: true,
        hour: 10,
        minute: 30,
        daysOfWeek: {1, 2, 3},
      );

      expect(updated.enabled, true);
      expect(updated.hour, 10);
      expect(updated.minute, 30);
      expect(updated.daysOfWeek, {1, 2, 3});

      expect(original.enabled, false);
      expect(original.hour, 9);
    });

    test('toJson and fromJson round-trip correctly', () {
      const original = ReminderSettings(
        enabled: true,
        hour: 15,
        minute: 45,
        daysOfWeek: {1, 3, 5, 7},
      );

      final json = original.toJson();
      final restored = ReminderSettings.fromJson(json);

      expect(restored.enabled, original.enabled);
      expect(restored.hour, original.hour);
      expect(restored.minute, original.minute);
      expect(restored.daysOfWeek, original.daysOfWeek);
    });

    test('equality works correctly', () {
      const settings1 = ReminderSettings(
        enabled: true,
        hour: 9,
        minute: 0,
        daysOfWeek: {1, 2, 3},
      );
      const settings2 = ReminderSettings(
        enabled: true,
        hour: 9,
        minute: 0,
        daysOfWeek: {1, 2, 3},
      );
      const settings3 = ReminderSettings(
        enabled: false,
        hour: 9,
        minute: 0,
        daysOfWeek: {1, 2, 3},
      );

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });
}
