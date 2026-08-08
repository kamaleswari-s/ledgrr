import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScannerService {
  final _recognizer = TextRecognizer();

  Future<String> scanText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  /// Finds the total by taking the last valid monetary number in the
  /// document, after filtering out anything that clearly is not
  /// money — phone numbers, percentages, times, dates, invoice and
  /// reference numbers. Across every real receipt tested, from a
  /// simple two-item bill to a ten-item supermarket list with a
  /// subtotal and discount, the actual total was consistently the
  /// last genuine number printed, this is a deliberately simple,
  /// evidence-based rule rather than a cleverer one that kept
  /// breaking on different receipt layouts.
  double? extractTotal(String rawText) {
    var text = rawText;

    final timePattern = RegExp(r'\d{1,2}:\d{2}(:\d{2})?');
    text = text.replaceAll(timePattern, '');

    final datePattern = RegExp(r'\b\d{1,2}[-/]\d{1,2}[-/]\d{2,4}\b');
    text = text.replaceAll(datePattern, '');

    final phonePattern = RegExp(r'(\+?91[\s-]?)?\d{5}[\s-]?\d{5}\b');
    text = text.replaceAll(phonePattern, '');

    final percentPattern = RegExp(r'\d+\.?\d*\s*%');
    text = text.replaceAll(percentPattern, '');

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final excludePatterns = [
      'invoice', 'hsn', 'sac', 'gstin', 'phone', 'ph.', 'ph:',
      'mobile', 'contact', 'bill no', 'table', 'waiter', 'account',
      'ifsc', 'branch',
    ];
    bool isExcluded(String line) {
      final lower = line.toLowerCase();
      return excludePatterns.any((p) => lower.contains(p));
    }

    double? lastNumber;
    for (final line in lines) {
      if (isExcluded(line)) continue;
      final match = _extractNumberFrom(line);
      if (match != null && match > 0 && match < 1000000) {
        lastNumber = match;
      }
    }
    return lastNumber;
  }

  double? _extractNumberFrom(String text) {
    var cleaned = text.replaceAllMapped(
      RegExp(r'(?<=\d)[Oo](?=\d)|(?<=\d)[Oo](?=[.\-])|(?<=[.\-])[Oo](?=\d)'),
      (m) => '0',
    );
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(\d)-(\d{2})\b'),
      (m) => '${m[1]}.${m[2]}',
    );

    final regex = RegExp(r'[\d,]+\.?\d*');
    final matches = regex.allMatches(cleaned);
    double? best;
    for (final m in matches) {
      final numStr = m.group(0)!.replaceAll(',', '');
      final value = double.tryParse(numStr);
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