import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/models/entry.dart';
import '../../data/models/export_options.dart';
import '../../data/repositories/entry_repository.dart';

class ExportService {
  final EntryRepository _entryRepository;

  ExportService({required EntryRepository entryRepository})
      : _entryRepository = entryRepository;

  Future<List<Entry>> _getEntriesToExport(ExportOptions options) async {
    List<Entry> entries;

    if (options.startDate != null && options.endDate != null) {
      entries = await _entryRepository.getEntriesForDateRange(
        options.startDate!,
        options.endDate!,
      );
    } else {
      entries = await _entryRepository.getAllEntries();
    }

    // Sort by date, newest first
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<ExportResult> export(ExportOptions options) async {
    try {
      final entries = await _getEntriesToExport(options);

      if (entries.isEmpty) {
        return ExportResult.failure('No entries to export');
      }

      String content;
      String fileName;
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      switch (options.format) {
        case ExportFormat.markdown:
          content = _generateMarkdown(entries, options);
          fileName = 'journal_export_$dateStr.md';
          break;
        case ExportFormat.json:
          content = _generateJson(entries, options);
          fileName = 'journal_export_$dateStr.json';
          break;
        case ExportFormat.pdf:
          return await _exportPdf(entries, options, dateStr);
      }

      final filePath = await _saveToFile(content, fileName);
      return ExportResult.success(
        filePath: filePath,
        entryCount: entries.length,
      );
    } catch (e) {
      return ExportResult.failure('Export failed: $e');
    }
  }

  String _generateMarkdown(List<Entry> entries, ExportOptions options) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    buffer.writeln('# Journal Entries');
    buffer.writeln();

    if (options.startDate != null && options.endDate != null) {
      buffer.writeln(
        '> Exported: ${dateFormat.format(options.startDate!)} - ${dateFormat.format(options.endDate!)}',
      );
    } else {
      buffer.writeln('> Exported: All entries');
    }
    buffer.writeln('> Total entries: ${entries.length}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    String? currentDate;
    for (final entry in entries) {
      final entryDate = dateFormat.format(entry.createdAt);

      if (currentDate != entryDate) {
        currentDate = entryDate;
        buffer.writeln('## $entryDate');
        buffer.writeln();
      }

      buffer.writeln('### ${entry.stemText}');
      buffer.writeln();
      buffer.writeln(entry.completion);
      buffer.writeln();

      if (options.includeMetadata) {
        buffer.writeln('*${timeFormat.format(entry.createdAt)}*');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  String _generateJson(List<Entry> entries, ExportOptions options) {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'entryCount': entries.length,
      if (options.startDate != null)
        'startDate': options.startDate!.toIso8601String(),
      if (options.endDate != null)
        'endDate': options.endDate!.toIso8601String(),
      'entries': entries.map((e) {
        final map = {
          'stemText': e.stemText,
          'completion': e.completion,
          'createdAt': e.createdAt.toIso8601String(),
        };
        if (options.includeMetadata) {
          map['id'] = e.id;
          map['stemId'] = e.stemId;
          map['categoryId'] = e.categoryId;
          if (e.parentEntryId != null) {
            map['parentEntryId'] = e.parentEntryId!;
          }
        }
        return map;
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<ExportResult> _exportPdf(
    List<Entry> entries,
    ExportOptions options,
    String dateStr,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Group entries by date
    final entriesByDate = <String, List<Entry>>{};
    for (final entry in entries) {
      final date = dateFormat.format(entry.createdAt);
      entriesByDate.putIfAbsent(date, () => []).add(entry);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[];

          // Title
          widgets.add(
            pw.Header(
              level: 0,
              child: pw.Text(
                'Journal Entries',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );

          widgets.add(
            pw.Paragraph(
              text: 'Total entries: ${entries.length}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          );

          widgets.add(pw.SizedBox(height: 20));

          // Entries grouped by date
          for (final dateEntry in entriesByDate.entries) {
            widgets.add(
              pw.Header(
                level: 1,
                child: pw.Text(
                  dateEntry.key,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            for (final entry in dateEntry.value) {
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        entry.stemText,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        entry.completion,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      if (options.includeMetadata) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          timeFormat.format(entry.createdAt),
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'journal_export_$dateStr.pdf';
    final filePath = await _saveBytesToFile(bytes, fileName);

    return ExportResult.success(
      filePath: filePath,
      entryCount: entries.length,
    );
  }

  Future<String> _saveToFile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> _saveBytesToFile(List<int> bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> shareExportedFile(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], text: 'My journal entries');
  }
}
