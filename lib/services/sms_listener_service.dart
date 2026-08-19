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
        if (body == null) return;

        final parsed = SmsParser.parse(body);
        if (parsed != null) {
          onTransactionDetected(parsed);
          return;
        }

        final isCanara = body.toLowerCase().contains('canara') ||
            body.toLowerCase().contains('canbnk');
        if (isCanara) {
          _logUnmatchedMessage(body);
        }
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
      // Silently fail.
    }
  }
}