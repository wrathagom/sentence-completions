import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentence_completion/data/models/share_card_options.dart';
import 'package:sentence_completion/presentation/widgets/share_card_preview.dart';

void main() {
  group('ShareCardStyle', () {
    test('fromValue returns correct style', () {
      expect(ShareCardStyle.fromValue('minimal'), ShareCardStyle.minimal);
      expect(ShareCardStyle.fromValue('dark'), ShareCardStyle.dark);
      expect(ShareCardStyle.fromValue('gradient'), ShareCardStyle.gradient);
      expect(ShareCardStyle.fromValue('nature'), ShareCardStyle.nature);
      expect(ShareCardStyle.fromValue('sunset'), ShareCardStyle.sunset);
      expect(ShareCardStyle.fromValue('ocean'), ShareCardStyle.ocean);
    });

    test('fromValue returns minimal for unknown value', () {
      expect(ShareCardStyle.fromValue('unknown'), ShareCardStyle.minimal);
    });

    test('hasGradient returns true for gradient styles', () {
      expect(ShareCardStyle.gradient.hasGradient, isTrue);
      expect(ShareCardStyle.nature.hasGradient, isTrue);
      expect(ShareCardStyle.sunset.hasGradient, isTrue);
      expect(ShareCardStyle.ocean.hasGradient, isTrue);
    });

    test('hasGradient returns false for non-gradient styles', () {
      expect(ShareCardStyle.minimal.hasGradient, isFalse);
      expect(ShareCardStyle.dark.hasGradient, isFalse);
    });

    test('gradientEndColor is null for non-gradient styles', () {
      expect(ShareCardStyle.minimal.gradientEndColor, isNull);
      expect(ShareCardStyle.dark.gradientEndColor, isNull);
    });

    test('gradientEndColor is not null for gradient styles', () {
      expect(ShareCardStyle.gradient.gradientEndColor, isNotNull);
      expect(ShareCardStyle.nature.gradientEndColor, isNotNull);
      expect(ShareCardStyle.sunset.gradientEndColor, isNotNull);
      expect(ShareCardStyle.ocean.gradientEndColor, isNotNull);
    });
  });

  group('ShareCardOptions', () {
    test('default constructor uses expected defaults', () {
      const options = ShareCardOptions();

      expect(options.style, ShareCardStyle.minimal);
      expect(options.showCategory, isTrue);
      expect(options.showDate, isTrue);
      expect(options.showAppBranding, isTrue);
      expect(options.fontSize, 24.0);
    });

    test('copyWith creates new instance with updated values', () {
      const original = ShareCardOptions();
      final updated = original.copyWith(
        style: ShareCardStyle.dark,
        showCategory: false,
        fontSize: 28.0,
      );

      expect(updated.style, ShareCardStyle.dark);
      expect(updated.showCategory, isFalse);
      expect(updated.showDate, isTrue); // unchanged
      expect(updated.showAppBranding, isTrue); // unchanged
      expect(updated.fontSize, 28.0);
    });
  });

  group('ShareCardResult', () {
    test('success factory creates successful result', () {
      final result = ShareCardResult.success('/path/to/file.png');

      expect(result.success, isTrue);
      expect(result.filePath, '/path/to/file.png');
      expect(result.error, isNull);
    });

    test('failure factory creates failed result', () {
      final result = ShareCardResult.failure('Something went wrong');

      expect(result.success, isFalse);
      expect(result.filePath, isNull);
      expect(result.error, 'Something went wrong');
    });
  });

  group('ShareCardPreview Widget', () {
    testWidgets('renders stem text with ellipsis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'When I feel stressed, I',
              createdAt: DateTime(2024, 6, 15),
            ),
          ),
        ),
      );

      expect(find.text('When I feel stressed, I...'), findsOneWidget);
    });

    testWidgets('shows category when showCategory is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'Test stem',
              categoryName: 'Self-Awareness',
              createdAt: DateTime(2024, 6, 15),
              options: const ShareCardOptions(showCategory: true),
            ),
          ),
        ),
      );

      expect(find.text('Self-Awareness'), findsOneWidget);
    });

    testWidgets('hides category when showCategory is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'Test stem',
              categoryName: 'Self-Awareness',
              createdAt: DateTime(2024, 6, 15),
              options: const ShareCardOptions(showCategory: false),
            ),
          ),
        ),
      );

      expect(find.text('Self-Awareness'), findsNothing);
    });

    testWidgets('shows date when showDate is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'Test stem',
              createdAt: DateTime(2024, 6, 15),
              options: const ShareCardOptions(showDate: true),
            ),
          ),
        ),
      );

      expect(find.text('Jun 15, 2024'), findsOneWidget);
    });

    testWidgets('hides date when showDate is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'Test stem',
              createdAt: DateTime(2024, 6, 15),
              options: const ShareCardOptions(showDate: false),
            ),
          ),
        ),
      );

      expect(find.text('Jun 15, 2024'), findsNothing);
    });

    testWidgets('shows branding when showAppBranding is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'Test stem',
              createdAt: DateTime(2024, 6, 15),
              options: const ShareCardOptions(showAppBranding: true),
            ),
          ),
        ),
      );

      expect(find.text('Sentence Completion'), findsOneWidget);
    });

    testWidgets('hides branding when showAppBranding is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardPreview(
              stemText: 'Test stem',
              createdAt: DateTime(2024, 6, 15),
              options: const ShareCardOptions(showAppBranding: false),
            ),
          ),
        ),
      );

      expect(find.text('Sentence Completion'), findsNothing);
    });
  });

  group('ShareCardStyleSelector Widget', () {
    testWidgets('shows all style options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardStyleSelector(
              selectedStyle: ShareCardStyle.minimal,
              onStyleChanged: (_) {},
            ),
          ),
        ),
      );

      for (final style in ShareCardStyle.values) {
        expect(find.text(style.label), findsOneWidget);
      }
    });

    testWidgets('calls onStyleChanged when style is tapped', (tester) async {
      ShareCardStyle? selectedStyle;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCardStyleSelector(
              selectedStyle: ShareCardStyle.minimal,
              onStyleChanged: (style) {
                selectedStyle = style;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Dark'));
      await tester.pump();

      expect(selectedStyle, ShareCardStyle.dark);
    });
  });
}
