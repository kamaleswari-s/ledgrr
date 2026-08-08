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
  /// text off a receipt. Looks for lines containing words like
  /// "total", "amount", "grand total" followed by a number, and
  /// falls back to the largest number found anywhere in the text
  /// if no labeled total is found.
  double? extractTotal(String rawText) {
    final lines = rawText.split('\n');
    final totalKeywords = ['total', 'amount', 'grand total', 'net amount'];

    // First pass: look for a line containing a total-related keyword.
    for (final line in lines) {
      final lower = line.toLowerCase();
      final hasKeyword =
          totalKeywords.any((keyword) => lower.contains(keyword));
      if (hasKeyword) {
        final match = _extractNumberFrom(line);
        if (match != null) return match;
      }
    }

    // Fallback: grab every number found in the whole text, return
    // the largest one — usually the total on a simple receipt.
    final allNumbers = <double>[];
    for (final line in lines) {
      final number = _extractNumberFrom(line);
      if (number != null) allNumbers.add(number);
    }
    if (allNumbers.isEmpty) return null;
    allNumbers.sort();
    return allNumbers.last;
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