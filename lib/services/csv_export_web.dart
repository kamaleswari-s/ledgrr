import 'dart:js_interop';
import 'package:web/web.dart' as web;

// Web implementation — triggers a real browser download.
void downloadCsv(String csvContent, String fileName) {
  final blobParts = [csvContent.toJS].toJS;
  final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'text/csv'));
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);

  web.URL.revokeObjectURL(url);
}