import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScannerService {
  final _recognizer = TextRecognizer();

  /// Scans an image file and returns the raw recognized text.
  Future<String> scanText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  /// Attempts to find the most likely "total" amount from raw OCR
  /// text off a receipt. Looks for lines containing total-related
  /// keywords, checked in priority order from most specific to most
  /// generic, so "grand total" is trusted over a plain "total" if
  /// both appear on the same receipt. Deliberately does not fall
  /// back to "largest number found" — that approach is unreliable
  /// on real receipts, which often contain phone numbers, GST
  /// numbers, or item codes larger than the actual total. If no
  /// labeled total is found, returns null so the user can enter the
  /// amount manually rather than risk logging a wrong number.
  double? extractTotal(String rawText) {
    final lines = rawText.split('\n');
    final totalKeywords = [
      'grand total',
      'net amount',
      'net total',
      'total amount',
      'amount payable',
      'total',
      'amount',
    ];

    for (final keyword in totalKeywords) {
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (lower.contains(keyword)) {
          final match = _extractNumberFrom(line);
          // Reject obviously wrong matches — phone numbers, long
          // reference codes, etc. tend to be unusually large or
          // have too many digits for a real bill amount.
          if (match != null && match > 0 && match < 1000000) {
            return match;
          }
        }
      }
    }

    return null;
  }

  double? _extractNumberFrom(String text) {
    // Matches numbers like 450, 450.00, 1,250.50 — strips commas
    // before parsing.
    final regex = RegExp(r'[\d,]+\.?\d*');
    final matches = regex.allMatches(text);
    double? best;
    for (final m in matches) {
      final cleaned = m.group(0)!.replaceAll(',', '');
      final value = double.tryParse(cleaned);
      if (value != null && value > 0) {
        if (best == null || value > best) best = value;
      }
    }
    return best;
  }

  void dispose() {
    _recognizer.close();
  }
}