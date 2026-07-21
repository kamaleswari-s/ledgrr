import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';
import '../home/home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _balanceController = TextEditingController();
  final _incomeController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final _transactionService = TransactionService();

  @override
  void dispose() {
    _balanceController.dispose();
    _incomeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0;
    final income = double.tryParse(_incomeController.text.trim()) ?? 0;
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0;

    if (balance == 0) {
      setState(() => _errorMessage = 'Please enter your current balance.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save opening balance as first income transaction
      await _transactionService.addTransaction(
        title: 'Opening Balance',
        amount: balance,
        category: 'other_income',
        type: 'income',
        date: DateTime.now(),
        note: 'Starting balance set during setup',
      );

      // Save monthly income and budget to user profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'monthlyIncome': income,
        'monthlyBudget': budget,
        'setupComplete': true,
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? palette.accent
                            : palette.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // Page 1 — Current balance
                  _SetupPage(
                    palette: palette,
                    stepNumber: '01',
                    title: 'What is your\ncurrent balance?',
                    subtitle: 'Add up all the money you have right now — bank account, cash, UPI wallet. Everything combined.',
                    hint: 'This is your starting point. LEDGRR tracks from here.',
                    child: _AmountField(
                      controller: _balanceController,
                      hint: '0.00',
                      label: 'Current total balance (₹)',
                      palette: palette,
                      helpText: 'Bank balance + cash in hand + UPI wallets (PhonePe, Paytm, GPay). Do not include FDs or money people owe you.',
                    ),
                  ),

                  // Page 2 — Monthly income
                  _SetupPage(
                    palette: palette,
                    stepNumber: '02',
                    title: 'How much do you\nearn or receive monthly?',
                    subtitle: 'This includes your salary, pocket money from family, freelance income — anything that comes in regularly.',
                    hint: 'Not sure? Enter your best estimate. You can update this anytime.',
                    child: _AmountField(
                      controller: _incomeController,
                      hint: '0.00',
                      label: 'Monthly income or allowance (₹)',
                      palette: palette,
                      helpText: 'Average Indian college student receives ₹5,000 to ₹15,000 per month.',
                      isOptional: true,
                    ),
                  ),

                  // Page 3 — Monthly budget
                  _SetupPage(
                    palette: palette,
                    stepNumber: '03',
                    title: 'Set your monthly\nspending limit.',
                    subtitle: 'How much do you want to spend this month at most? This helps LEDGRR warn you before you overspend.',
                    hint: 'A good rule — spend no more than 70% of your monthly income.',
                    child: Column(
                      children: [
                        _AmountField(
                          controller: _budgetController,
                          hint: '0.00',
                          label: 'Monthly spending limit (₹)',
                          palette: palette,
                          helpText: 'You can always adjust this later in settings.',
                          isOptional: true,
                        ),
                        if (_incomeController.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          // Smart suggestion
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: palette.bg2,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: palette.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded,
                                    color: palette.accent, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Based on your income, a healthy budget is ₹${((double.tryParse(_incomeController.text) ?? 0) * 0.7).toStringAsFixed(0)} per month.',
                                    style: GoogleFonts.syne(
                                      fontSize: 12,
                                      color: palette.ink,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFE53935).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFE53935), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.syne(
                              fontSize: 12,
                              color: const Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Material(
                color: palette.accent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading ? null : _next,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: palette.accentFg,
                              ),
                            )
                          : Text(
                              _currentPage < 2 ? 'Continue' : 'Start using LEDGRR',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                color: palette.accentFg,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SETUP PAGE ────────────────────────────────────────────────────────────

class _SetupPage extends StatelessWidget {
  final LedgrrPalette palette;
  final String stepNumber;
  final String title;
  final String subtitle;
  final String hint;
  final Widget child;

  const _SetupPage({
    required this.palette,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: palette.accent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: palette.ink,
              letterSpacing: -1,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            subtitle,
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: palette.inkMuted,
              height: 1.65,
            ),
          ),

          const SizedBox(height: 32),

          child,

          const SizedBox(height: 16),

          // Hint box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: palette.accent, size: 15),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      color: palette.ink,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AMOUNT FIELD ──────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final LedgrrPalette palette;
  final String helpText;
  final bool isOptional;

  const _AmountField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.palette,
    required this.helpText,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.inkMuted,
                letterSpacing: 0.05,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: palette.border),
                ),
                child: Text(
                  'Optional',
                  style: GoogleFonts.syne(
                      fontSize: 10, color: palette.inkMuted),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: palette.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '₹',
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: palette.border,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          helpText,
          style: GoogleFonts.syne(
            fontSize: 11,
            color: palette.inkMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}