import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/share_card_options.dart';

/// Service for generating and sharing card images
class ShareCardService {
  final ScreenshotController screenshotController;

  ShareCardService({ScreenshotController? controller})
      : screenshotController = controller ?? ScreenshotController();

  /// Captures the widget and saves it as an image file
  Future<ShareCardResult> captureAndSave({
    required Widget widget,
    required String entryId,
    double pixelRatio = 3.0,
  }) async {
    try {
      final imageBytes = await screenshotController.captureFromWidget(
        widget,
        pixelRatio: pixelRatio,
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/share_card_${entryId}_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return ShareCardResult.success(filePath);
    } catch (e) {
      return ShareCardResult.failure('Error generating image: $e');
    }
  }

  /// Shares the card image using the system share dialog
  Future<void> shareImage(String filePath, {String? text}) async {
    final xFile = XFile(filePath);
    await Share.shareXFiles(
      [xFile],
      text: text,
    );
  }

  /// Captures and immediately shares the card
  Future<ShareCardResult> captureAndShare({
    required Widget widget,
    required String entryId,
    String? shareText,
    double pixelRatio = 3.0,
  }) async {
    final result = await captureAndSave(
      widget: widget,
      entryId: entryId,
      pixelRatio: pixelRatio,
    );

    if (result.success && result.filePath != null) {
      await shareImage(result.filePath!, text: shareText);
    }

    return result;
  }

  /// Cleans up temporary share card files
  Future<void> cleanupTempFiles() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = directory.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('share_card_')) {
          await file.delete();
        }
      }
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}
