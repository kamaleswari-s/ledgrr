import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sms_parser.dart';

class SmsListenerService {
  final Telephony _telephony = Telephony.instance;

  Future<void> startListening({
    required void Function(ParsedTransaction) onTransactionDetected,
  }) async {
    if (!Platform.isAndroid) return;

    final permissionsGranted = await _telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != true) return;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final body = message.body;
        final sender = message.address ?? '';
        if (body == null) return;

        // Only process messages from Canara Bank's actual sender IDs,
        // not just any message that happens to mention "Canara" in
        // the text. Real bank SMS come from short codes like CANBNK
        // or AD-CANBNK, never from a regular ten-digit number, so
        // this stops a random text from a friend or contact being
        // treated as a real bank transaction.
        final isFromCanara = sender.toUpperCase().contains('CANBNK') ||
            sender.toUpperCase().contains('CANARA');
        if (!isFromCanara) return;

        final parsed = SmsParser.parse(body);
        if (parsed != null) {
          onTransactionDetected(parsed);
          return;
        }

        // Sender was confirmed as Canara, but the message body didn't
        // match any of our known templates. Log it quietly instead of
        // dropping it, so there's a trail to check later without
        // interrupting the user.
        _logUnmatchedMessage(body);
      },
      listenInBackground: false,
    );
  }

  Future<void> _logUnmatchedMessage(String body) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('unmatchedSms')
          .add({
        'body': body,
        'receivedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail. This is a nice-to-have log, never something
      // that should interrupt the user or crash the listener.
    }
  }
}