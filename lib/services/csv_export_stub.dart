import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Mobile implementation — saves the CSV to a temporary file, then
// opens the native share sheet so the user can save it, email it,
// or send it wherever they like.
Future<void> downloadCsv(String csvContent, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(csvContent);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Your LEDGRR transaction export',
  );
}