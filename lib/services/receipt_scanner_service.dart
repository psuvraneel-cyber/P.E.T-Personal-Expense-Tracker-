import 'package:flutter/foundation.dart';
import 'package:pet/core/utils/app_logger.dart';

/// Receipt scanning service for OCR-based transaction extraction.
///
/// This service uses Google ML Kit Text Recognition to extract
/// merchant name, amount, and date from photographed receipts.
///
/// **Integration requires:**
/// - `google_mlkit_text_recognition` package
/// - `image_picker` package
/// - Camera permission in AndroidManifest.xml
///
/// The actual ML Kit processing is stubbed here until the packages
/// are added to `pubspec.yaml`. The architecture is ready for
/// plug-and-play integration.
class ReceiptScannerService {
  ReceiptScannerService._();
  static final ReceiptScannerService instance = ReceiptScannerService._();

  /// Extract transaction data from the image at [imagePath].
  ///
  /// Returns a [ReceiptData] with extracted fields, or `null`
  /// if no meaningful data could be extracted.
  Future<ReceiptData?> scanReceipt(String imagePath) async {
    try {
      // TODO: Integrate google_mlkit_text_recognition
      // final inputImage = InputImage.fromFilePath(imagePath);
      // final textRecognizer = TextRecognizer();
      // final recognizedText = await textRecognizer.processImage(inputImage);
      // textRecognizer.close();
      //
      // return _parseReceiptText(recognizedText.text);

      AppLogger.debug(
        '[ReceiptScanner] ML Kit not yet integrated — returning null',
      );
      return null;
    } catch (e) {
      AppLogger.debug('[ReceiptScanner] Error: $e');
      return null;
    }
  }

  /// Parse raw OCR text to extract structured receipt data.
  ReceiptData? parseReceiptText(String text) {
    double? amount;
    String? merchant;
    DateTime? date;

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 1. Extract amount — look for patterns like ₹1,234.56 or Rs. 1234
    final amountRegex = RegExp(
      r'(?:₹|Rs\.?|INR)\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = amountRegex.firstMatch(line);
      if (match != null) {
        final raw = match.group(1)?.replaceAll(',', '');
        amount = double.tryParse(raw ?? '');
        if (amount != null && amount > 0) break;
      }
    }

    // 2. Extract merchant — typically one of the first non-numeric lines
    for (final line in lines.take(5)) {
      if (!amountRegex.hasMatch(line) && line.length > 2 && line.length < 50) {
        merchant = line;
        break;
      }
    }

    // 3. Extract date — look for common Indian date formats
    final dateRegex = RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        final day = int.tryParse(match.group(1) ?? '') ?? 0;
        final month = int.tryParse(match.group(2) ?? '') ?? 0;
        var year = int.tryParse(match.group(3) ?? '') ?? 0;
        if (year < 100) year += 2000;
        if (day > 0 && month > 0 && year > 2000) {
          date = DateTime(year, month, day);
          break;
        }
      }
    }

    if (amount == null) return null;

    return ReceiptData(
      amount: amount,
      merchant: merchant,
      date: date,
      rawText: text,
    );
  }
}

/// Data extracted from a scanned receipt.
@immutable
class ReceiptData {
  final double amount;
  final String? merchant;
  final DateTime? date;
  final String rawText;

  const ReceiptData({
    required this.amount,
    this.merchant,
    this.date,
    required this.rawText,
  });
}
