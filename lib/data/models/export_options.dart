enum ExportFormat {
  markdown,
  json,
  pdf;

  String get displayName {
    switch (this) {
      case ExportFormat.markdown:
        return 'Markdown';
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.markdown:
        return 'md';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.markdown:
        return 'text/markdown';
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }
}

class ExportOptions {
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeMetadata;

  const ExportOptions({
    required this.format,
    this.startDate,
    this.endDate,
    this.includeMetadata = true,
  });

  ExportOptions copyWith({
    ExportFormat? format,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeMetadata,
  }) {
    return ExportOptions(
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeMetadata: includeMetadata ?? this.includeMetadata,
    );
  }
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final int entryCount;

  const ExportResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    required this.entryCount,
  });

  factory ExportResult.success({
    required String filePath,
    required int entryCount,
  }) {
    return ExportResult(
      success: true,
      filePath: filePath,
      entryCount: entryCount,
    );
  }

  factory ExportResult.failure(String errorMessage) {
    return ExportResult(
      success: false,
      errorMessage: errorMessage,
      entryCount: 0,
    );
  }
}
