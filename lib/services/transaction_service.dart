import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Add a transaction
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type, // 'income' or 'expense'
    required DateTime date,
    String note = '',
  }) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .add({
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _updateStreak();
  }

  // Updates the user's daily logging streak. Called whenever a
  // transaction is added. Quiet by design — no notifications, no
  // punishment for breaking it, just a simple count.
  Future<void> _updateStreak() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final userRef = _db.collection('users').doc(_uid);
    final userDoc = await userRef.get();
    final data = userDoc.data() ?? {};

    final lastLoggedDate = data['lastLoggedDate'] as String?;
    final currentStreak = (data['currentStreak'] as num?)?.toInt() ?? 0;
    final longestStreak = (data['longestStreak'] as num?)?.toInt() ?? 0;

    if (lastLoggedDate == today) {
      // Already logged today — no change.
      return;
    }

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    final newStreak = lastLoggedDate == yesterday ? currentStreak + 1 : 1;

    await userRef.set({
      'lastLoggedDate': today,
      'currentStreak': newStreak,
      'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
    }, SetOptions(merge: true));
  }

  // Get all transactions stream
  Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get transactions for a specific month
  Stream<QuerySnapshot> getMonthlyTransactions(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    return _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get transactions for a specific date
  Stream<QuerySnapshot> getDailyTransactions(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // Update a transaction
  Future<void> updateTransaction({
    required String transactionId,
    required String title,
    required double amount,
    required String category,
    required String type,
    required DateTime date,
    String note = '',
  }) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc(transactionId)
        .update({
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': Timestamp.fromDate(date),
      'note': note,
    });
  }

  // Calculate true balance from all transactions
  Future<double> getTrueBalance() async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .get();

    double balance = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'income') {
        balance += (data['amount'] as num).toDouble();
      } else {
        balance -= (data['amount'] as num).toDouble();
      }
    }
    return balance;
  }
  // Get summary for a single specific day
  Future<Map<String, double>> getDailySummary(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    double income = 0;
    double expense = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'income') {
        income += (data['amount'] as num).toDouble();
      } else {
        expense += (data['amount'] as num).toDouble();
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
  // Get monthly summary
  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    double income = 0;
    double expense = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'income') {
        income += (data['amount'] as num).toDouble();
      } else {
        expense += (data['amount'] as num).toDouble();
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  // Get spending by category for a month
  Future<Map<String, double>> getCategorySpending(
      int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .where('type', isEqualTo: 'expense')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    final Map<String, double> categoryMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final category = data['category'] as String;
      final amount = (data['amount'] as num).toDouble();
      categoryMap[category] = (categoryMap[category] ?? 0) + amount;
    }

    return categoryMap;
  }
}