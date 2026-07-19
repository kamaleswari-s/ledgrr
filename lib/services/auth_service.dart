import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      await _db.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'currency': '₹',
        'monthlyBudget': 0,
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final doc = await _db
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(
        level: PasswordLevel.empty,
        score: 0,
        maxScore: 5,
        tips: [],
        label: '',
      );
    }

    int score = 0;
    final tips = <String>[];

    if (password.length >= 8) {
      score++;
    } else {
      tips.add('Use at least 8 characters');
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      score++;
    } else {
      tips.add('Add an uppercase letter');
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      score++;
    } else {
      tips.add('Add a number');
    }

    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      score++;
    } else {
      tips.add('Add a special character like ! or @');
    }

    if (password.length >= 12) score++;

    if (score <= 1) {
      return PasswordStrength(
        level: PasswordLevel.weak,
        score: score,
        maxScore: 5,
        tips: tips,
        label: 'Weak',
      );
    } else if (score <= 3) {
      return PasswordStrength(
        level: PasswordLevel.medium,
        score: score,
        maxScore: 5,
        tips: tips,
        label: 'Medium',
      );
    } else {
      return PasswordStrength(
        level: PasswordLevel.strong,
        score: score,
        maxScore: 5,
        tips: tips,
        label: 'Strong',
      );
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'This password is too weak. Make it stronger.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'That email address does not look right.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

enum PasswordLevel { empty, weak, medium, strong }

class PasswordStrength {
  final PasswordLevel level;
  final int score;
  final int maxScore;
  final List<String> tips;
  final String label;

  const PasswordStrength({
    required this.level,
    required this.score,
    required this.maxScore,
    required this.tips,
    required this.label,
  });
}