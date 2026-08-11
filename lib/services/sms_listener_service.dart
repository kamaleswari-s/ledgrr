import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'sms_parser.dart';

class SmsListenerService {
  final Telephony _telephony = Telephony.instance;

  // Call this once, typically from Home screen's initState
  Future<void> startListening({
    required void Function(ParsedTransaction) onTransactionDetected,
  }) async {
    if (!Platform.isAndroid) return;

    final permissionsGranted = await _telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != true) return;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final body = message.body;
        if (body == null) return;

        final parsed = SmsParser.parse(body);
        if (parsed != null) {
          onTransactionDetected(parsed);
        }
        // If parsed is null, it means either not a Canara message,
        // or a Canara message that didn't match any known template.
        // We deliberately do nothing here rather than showing an
        // error, so the user isn't interrupted by every unrelated SMS.
      },
      listenInBackground: false,
    );
  }
}