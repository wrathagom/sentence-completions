import 'package:flutter_test/flutter_test.dart';

import 'package:sentence_completion/data/models/mood.dart';

void main() {
  group('Mood', () {
    test('has correct values', () {
      expect(Mood.veryLow.value, 1);
      expect(Mood.low.value, 2);
      expect(Mood.neutral.value, 3);
      expect(Mood.good.value, 4);
      expect(Mood.veryGood.value, 5);
    });

    test('has correct emojis', () {
      expect(Mood.veryLow.emoji, '😢');
      expect(Mood.low.emoji, '😕');
      expect(Mood.neutral.emoji, '😐');
      expect(Mood.good.emoji, '🙂');
      expect(Mood.veryGood.emoji, '😊');
    });

    test('has correct labels', () {
      expect(Mood.veryLow.label, 'Very Low');
      expect(Mood.low.label, 'Low');
      expect(Mood.neutral.label, 'Neutral');
      expect(Mood.good.label, 'Good');
      expect(Mood.veryGood.label, 'Very Good');
    });

    test('fromValue returns correct mood', () {
      expect(Mood.fromValue(1), Mood.veryLow);
      expect(Mood.fromValue(2), Mood.low);
      expect(Mood.fromValue(3), Mood.neutral);
      expect(Mood.fromValue(4), Mood.good);
      expect(Mood.fromValue(5), Mood.veryGood);
    });

    test('fromValue returns null for null input', () {
      expect(Mood.fromValue(null), null);
    });

    test('fromValueNullable returns null for invalid value', () {
      expect(Mood.fromValueNullable(0), null);
      expect(Mood.fromValueNullable(6), null);
      expect(Mood.fromValueNullable(null), null);
    });

    test('displayLabel returns emoji and label', () {
      expect(Mood.veryGood.displayLabel, '😊 Very Good');
      expect(Mood.neutral.displayLabel, '😐 Neutral');
    });

    test('isPositive returns true for good and very good', () {
      expect(Mood.veryGood.isPositive, true);
      expect(Mood.good.isPositive, true);
      expect(Mood.neutral.isPositive, false);
      expect(Mood.low.isPositive, false);
      expect(Mood.veryLow.isPositive, false);
    });

    test('isNegative returns true for low and very low', () {
      expect(Mood.veryLow.isNegative, true);
      expect(Mood.low.isNegative, true);
      expect(Mood.neutral.isNegative, false);
      expect(Mood.good.isNegative, false);
      expect(Mood.veryGood.isNegative, false);
    });

    test('isNeutral returns true only for neutral', () {
      expect(Mood.neutral.isNeutral, true);
      expect(Mood.veryLow.isNeutral, false);
      expect(Mood.low.isNeutral, false);
      expect(Mood.good.isNeutral, false);
      expect(Mood.veryGood.isNeutral, false);
    });
  });
}
