import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/export_options.dart';
import '../../../domain/services/import_service.dart';
import '../../providers/providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.json;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeMetadata = true;
  bool _isExporting = false;
  bool _isImporting = false;

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

    // Use file picker for export
    final result = await exportService.exportToChosenLocation(options);

    if (!mounted) return;

    setState(() {
      _isExporting = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${result.entryCount} ${result.entryCount == 1 ? 'entry' : 'entries'} to ${result.filePath}',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (result.errorMessage != 'Export cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Export failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _import() async {
    setState(() {
      _isImporting = true;
    });

    final importService = ref.read(importServiceProvider);
    final result = await importService.importFromFile();

    if (!mounted) return;

    setState(() {
      _isImporting = false;
    });

    if (result.success) {
      // Refresh providers
      ref.invalidate(entriesProvider);
      ref.invalidate(favoriteEntriesProvider);
      if (result.settingsImported) {
        ref.invalidate(settingsProvider);
      }
      if (result.goalsImported > 0) {
        ref.invalidate(activeGoalsWithProgressProvider);
      }
      if (result.savedStemsImported > 0) {
        ref.invalidate(savedStemsProvider);
        ref.invalidate(savedStemCountProvider);
      }

      _showImportResultDialog(result);
    } else if (result.errorMessage != 'Import cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Import failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showImportResultDialog(ImportResult result) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully imported ${result.entriesImported} '
              '${result.entriesImported == 1 ? 'entry' : 'entries'}.',
            ),
            if (result.goalsImported > 0) ...[
              const SizedBox(height: 8),
              Text('${result.goalsImported} ${result.goalsImported == 1 ? 'goal' : 'goals'} restored.'),
            ],
            if (result.savedStemsImported > 0) ...[
              const SizedBox(height: 8),
              Text('${result.savedStemsImported} saved ${result.savedStemsImported == 1 ? 'stem' : 'stems'} restored.'),
            ],
            if (result.settingsImported) ...[
              const SizedBox(height: 8),
              const Text('Your settings have been restored.'),
            ],
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${result.errors.length} entries could not be imported:',
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result.errors
                        .take(5)
                        .map((e) => Text(
                              '- $e',
                              style: Theme.of(dialogContext).textTheme.bodySmall,
                            ))
                        .toList(),
                  ),
                ),
              ),
              if (result.errors.length > 5)
                Text(
                  '... and ${result.errors.length - 5} more',
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Import'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Export Section
          Text(
            'Export',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isExporting ? null : _export,
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export to File'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Import Section
          Text(
            'Import',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Restore entries from a previous JSON export. Imported entries will be added to your existing data.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isImporting ? null : _import,
            icon: _isImporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
            label: Text(_isImporting ? 'Importing...' : 'Import from File'),
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
        return 'Structured data format, useful for backups and importing back.';
      case ExportFormat.pdf:
        return 'Print-ready document format for sharing or keeping offline.';
    }
  }
}
