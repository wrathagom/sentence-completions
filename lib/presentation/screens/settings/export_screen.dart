import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/export_options.dart';
import '../../providers/providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.markdown;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeMetadata = true;
  bool _isExporting = false;

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: _startDate ?? now.subtract(const Duration(days: 30)),
      end: _endDate ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _export() async {
    setState(() {
      _isExporting = true;
    });

    final exportService = ref.read(exportServiceProvider);
    final options = ExportOptions(
      format: _selectedFormat,
      startDate: _startDate,
      endDate: _endDate,
      includeMetadata: _includeMetadata,
    );

    final result = await exportService.export(options);

    if (!mounted) return;

    setState(() {
      _isExporting = false;
    });

    if (result.success) {
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Complete'),
          content: Text(
            'Successfully exported ${result.entryCount} ${result.entryCount == 1 ? 'entry' : 'entries'} to ${_selectedFormat.displayName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('close'),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('share'),
              child: const Text('Share'),
            ),
          ],
        ),
      );

      if (action == 'share' && result.filePath != null) {
        await exportService.shareExportedFile(result.filePath!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Export failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Format',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ExportFormat>(
            segments: ExportFormat.values
                .map(
                  (format) => ButtonSegment(
                    value: format,
                    label: Text(format.displayName),
                    icon: Icon(_getFormatIcon(format)),
                  ),
                )
                .toList(),
            selected: {_selectedFormat},
            onSelectionChanged: (selection) {
              setState(() {
                _selectedFormat = selection.first;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            _getFormatDescription(_selectedFormat),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Date Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(
                _startDate != null && _endDate != null
                    ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                    : 'All entries',
              ),
              subtitle: Text(
                _startDate != null ? 'Custom range' : 'No date filter',
              ),
              trailing: _startDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearDateRange,
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _selectDateRange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Options',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Include metadata'),
            subtitle: const Text('Entry IDs, timestamps, and category info'),
            value: _includeMetadata,
            onChanged: (value) {
              setState(() {
                _includeMetadata = value;
              });
            },
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _isExporting ? null : _export,
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export'),
          ),
        ],
      ),
    );
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return Icons.description;
      case ExportFormat.json:
        return Icons.code;
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return 'Human-readable format, great for notes apps and archiving.';
      case ExportFormat.json:
        return 'Structured data format, useful for backups and importing elsewhere.';
      case ExportFormat.pdf:
        return 'Print-ready document format for sharing or keeping offline.';
    }
  }
}
