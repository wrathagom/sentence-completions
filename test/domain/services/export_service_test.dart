import 'package:flutter_test/flutter_test.dart';

import 'package:sentence_completion/data/models/export_options.dart';

void main() {
  group('ExportOptions', () {
    test('copyWith creates new instance with updated values', () {
      const original = ExportOptions(
        format: ExportFormat.markdown,
        includeMetadata: true,
      );

      final updated = original.copyWith(
        format: ExportFormat.json,
        includeMetadata: false,
      );

      expect(updated.format, ExportFormat.json);
      expect(updated.includeMetadata, false);
      expect(original.format, ExportFormat.markdown);
      expect(original.includeMetadata, true);
    });

    test('copyWith preserves original values when not specified', () {
      final original = ExportOptions(
        format: ExportFormat.pdf,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        includeMetadata: false,
      );

      final updated = original.copyWith(format: ExportFormat.json);

      expect(updated.format, ExportFormat.json);
      expect(updated.startDate, original.startDate);
      expect(updated.endDate, original.endDate);
      expect(updated.includeMetadata, false);
    });
  });

  group('ExportResult', () {
    test('success factory creates successful result', () {
      final result = ExportResult.success(
        filePath: '/path/to/file.md',
        entryCount: 5,
      );

      expect(result.success, true);
      expect(result.filePath, '/path/to/file.md');
      expect(result.entryCount, 5);
      expect(result.errorMessage, null);
    });

    test('failure factory creates failed result', () {
      final result = ExportResult.failure('Something went wrong');

      expect(result.success, false);
      expect(result.errorMessage, 'Something went wrong');
      expect(result.entryCount, 0);
      expect(result.filePath, null);
    });
  });

  group('ExportFormat', () {
    test('displayName returns correct values', () {
      expect(ExportFormat.markdown.displayName, 'Markdown');
      expect(ExportFormat.json.displayName, 'JSON');
      expect(ExportFormat.pdf.displayName, 'PDF');
    });

    test('extension returns correct values', () {
      expect(ExportFormat.markdown.extension, 'md');
      expect(ExportFormat.json.extension, 'json');
      expect(ExportFormat.pdf.extension, 'pdf');
    });

    test('mimeType returns correct values', () {
      expect(ExportFormat.markdown.mimeType, 'text/markdown');
      expect(ExportFormat.json.mimeType, 'application/json');
      expect(ExportFormat.pdf.mimeType, 'application/pdf');
    });
  });
}
