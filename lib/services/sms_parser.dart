class ParsedTransaction {
  final double amount;
  final String? merchant;
  final bool isCredit;
  final DateTime? date;

  ParsedTransaction({
    required this.amount,
    this.merchant,
    required this.isCredit,
    this.date,
  });
}

class SmsParser {
  // Template 1: "Acct XXXXXX Dr. INR 415.00 on 02/08/26 to Nykaa ERetai"
  static final _acctDrPattern = RegExp(
    r'Acct\s+\S+\s+Dr\.\s+INR\s+([\d,]+\.?\d*)\s+on\s+([\d/]+)\s+to\s+([^;]+);',
    caseSensitive: false,
  );

  // Template 2: "An amount of INR 70.00 has been DEBITED to your account XXXXXX on 11/06/2026"
  static final _amountDebitedPattern = RegExp(
    r'amount of INR\s+([\d,]+\.?\d*)\s+has been (DEBITED|CREDITED)\s+to your account\s+\S+\s+on\s+([\d/]+)',
    caseSensitive: false,
  );

  // Template 3: "Rs.900.00 paid thru A/C XXXXXX on 30-5-26 10:48:36 to VIJAYA HOSPITAL"
  static final _paidThruPattern = RegExp(
    r'Rs\.([\d,]+\.?\d*)\s+paid thru A/C\s+\S+\s+on\s+([\d\-]+)\s+[\d:]+\s+to\s+([^,]+),',
    caseSensitive: false,
  );

  static ParsedTransaction? parse(String smsBody) {
    // Only process Canara Bank messages
    final isCanara = smsBody.toLowerCase().contains('canara') ||
        smsBody.toLowerCase().contains('canbnk');
    if (!isCanara) return null;

    // Try Template 1: Acct Dr with merchant
    var match = _acctDrPattern.firstMatch(smsBody);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (amount == null) return null;
      return ParsedTransaction(
        amount: amount,
        merchant: match.group(3)?.trim(),
        isCredit: false,
        date: _parseDate(match.group(2)),
      );
    }

    // Try Template 3: paid thru with merchant
    match = _paidThruPattern.firstMatch(smsBody);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (amount == null) return null;
      return ParsedTransaction(
        amount: amount,
        merchant: match.group(3)?.trim(),
        isCredit: false,
        date: _parseDate(match.group(2)),
      );
    }

    // Try Template 2: amount has been DEBITED/CREDITED, no merchant
    match = _amountDebitedPattern.firstMatch(smsBody);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (amount == null) return null;
      final isCredit = match.group(2)!.toUpperCase() == 'CREDITED';
      return ParsedTransaction(
        amount: amount,
        merchant: null,
        isCredit: isCredit,
        date: _parseDate(match.group(3)),
      );
    }

    // No template matched
    return null;
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    try {
      final parts = raw.split(RegExp(r'[/\-]'));
      if (parts.length != 3) return null;

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      if (year < 100) year += 2000;

      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}