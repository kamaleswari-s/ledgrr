import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import '../../services/groq_service.dart';
import '../../services/receipt_scanner_service.dart';
import '../../services/notification_service.dart';
import '../onboarding/onboarding_screen.dart';
import '../calendar/calendar_screen.dart';
import '../spendlist/spendlist_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';
import '../ghost/ghost_screen.dart';
import '../memory/memory_screen.dart';
import '../learn/learn_screen.dart';
import '../ask/ask_screen.dart';
import '../history/history_screen.dart';
import '../piggybank/piggybank_screen.dart';
import '../dues/dues_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  int _currentNavIndex = 0;
  final _transactionService = TransactionService();
  final _authService = AuthService();
  final _groqService = GroqService();
  final _receiptScanner = ReceiptScannerService();
  final _notificationService = NotificationService();
  double _trueBalance = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  bool _isLoading = true;
  String _userName = '';
  int _currentStreak = 0;
  String? _aiSentence;
  List<Map<String, dynamic>> _upcomingEvents = [];
  int _statsRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _loadData();
    _loadUpcomingEvents();
    _loadDailySentence();
    _setupNotifications();
    _controller.forward();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final now = DateTime.now();
      final balance = await _transactionService.getTrueBalance();
      final summary = await _transactionService.getMonthlySummary(
        now.year, now.month,
      );
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final streak =
          (userDoc.data()?['currentStreak'] as num?)?.toInt() ?? 0;
      if (mounted) {
        setState(() {
          _trueBalance = balance;
          _monthlyIncome = summary['income'] ?? 0;
          _monthlyExpense = summary['expense'] ?? 0;
          _userName =
              user.displayName?.split(' ').first ?? 'there';
          _currentStreak = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDailySentence() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final today =
          DateTime.now().toIso8601String().substring(0, 10);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = userDoc.data();

      if (data != null &&
          data['dailySentenceDate'] == today &&
          (data['dailySentence'] as String?)?.isNotEmpty == true) {
        if (mounted) {
          setState(() => _aiSentence = data['dailySentence'] as String);
        }
        return;
      }

      final now = DateTime.now();
      final categories = await _transactionService.getCategorySpending(
        now.year, now.month,
      );

      final sentence = await _groqService.generateDailySentence(
        userName: _userName.isNotEmpty ? _userName : 'there',
        trueBalance: _trueBalance,
        monthlyIncome: _monthlyIncome,
        monthlyExpense: _monthlyExpense,
        topCategories: categories,
      );

      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'dailySentence': sentence,
          'dailySentenceDate': today,
        },
        SetOptions(merge: true),
      );

      if (mounted) setState(() => _aiSentence = sentence);
    } catch (e) {
      // Silently fall back
    }
  }

  Future<void> _loadUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final in30 = now.add(const Duration(days: 30));
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('events')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('date',
              isLessThanOrEqualTo: Timestamp.fromDate(in30))
          .orderBy('date')
          .get();
      if (mounted) {
        setState(() {
          _upcomingEvents = snapshot.docs
              .map((d) => {...d.data(), 'id': d.id})
              .toList();
        });
      }
    } catch (e) {
      // silently fail
    }
  }

  Future<void> _setupNotifications() async {
    try {
      await _notificationService.initialize();
      final granted = await _notificationService.requestPermission();
      if (!granted) return;

      final today = DateTime.now();
      final dayData = await _transactionService.getDailySummary(today);
      final loggedToday =
          (dayData['income']! > 0) || (dayData['expense']! > 0);

      await _notificationService.scheduleDailyReminders(
        loggedToday: loggedToday,
        currentStreak: _currentStreak,
      );
    } catch (e) {
      // Silently fail — notifications are a nice-to-have, never
      // something that should block the app from working.
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool get _isStable {
    if (_trueBalance < 0) return false;
    if (_monthlyIncome > 0 && _monthlyExpense > _monthlyIncome) {
      return false;
    }
    if (_monthlyExpense > 0 && _trueBalance < _monthlyExpense) {
      return false;
    }
    return true;
  }

  String get _dailySentence {
    if (_isLoading) return 'Loading your financial truth...';
    if (_aiSentence != null && _aiSentence!.isNotEmpty) {
      return _aiSentence!;
    }
    if (_trueBalance == 0 && _monthlyExpense == 0) {
      return 'Welcome to LEDGRR. Add your first transaction to get started.';
    }
    if (!_isStable) {
      return 'Your spending is outpacing your income. Let\'s take a closer look.';
    }
    return 'You\'re stable. Keep tracking and LEDGRR will show you the full picture.';
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000)
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _receiptScanner.dispose();
    super.dispose();
  }

  void _showNotifications(BuildContext context, LedgrrPalette palette) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Notifications',
                style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                    letterSpacing: -0.5)),
            const SizedBox(height: 16),
            if (_upcomingEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Nothing new right now.',
                      style: GoogleFonts.syne(
                          fontSize: 13, color: palette.inkMuted)),
                ),
              )
            else
              ..._upcomingEvents.map((e) {
                final date = (e['date'] as Timestamp).toDate();
                final days = date.difference(DateTime.now()).inDays;
                final name = e['name'] ?? 'Upcoming event';
                final budget = (e['budget'] as num?)?.toDouble() ?? 0;
                final saved =
                    (e['savedAmount'] as num?)?.toDouble() ?? 0;
                final timeLabel = days == 0
                    ? 'today'
                    : days == 1
                        ? 'tomorrow'
                        : 'in $days days';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentNavIndex = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                color: palette.accent, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('$name is $timeLabel',
                                      style: GoogleFonts.syne(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: palette.ink)),
                                  if (budget > 0)
                                    Text(
                                        'Saved ₹${saved.toStringAsFixed(0)} of ₹${budget.toStringAsFixed(0)} goal.',
                                        style: GoogleFonts.syne(
                                            fontSize: 11,
                                            color: palette.inkMuted)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: palette.accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _scanReceipt(
      BuildContext context, LedgrrPalette palette) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan a receipt',
                style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: palette.ink)),
            const SizedBox(height: 4),
            Text('LEDGRR will try to read the total for you.',
                style: GoogleFonts.syne(
                    fontSize: 12, color: palette.inkMuted)),
            const SizedBox(height: 20),
            Material(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context, ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: palette.accent, size: 20),
                      const SizedBox(width: 12),
                      Text('Take a photo',
                          style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: palette.ink)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: palette.bg2,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo_library_outlined,
                          color: palette.accent, size: 20),
                      const SizedBox(width: 12),
                      Text('Choose from gallery',
                          style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: palette.ink)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile =
        await picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile == null) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: palette.accent),
      ),
    );

    try {
      final rawText =
          await _receiptScanner.scanText(File(pickedFile.path));
      final total = _receiptScanner.extractTotal(rawText);

      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;

      if (total == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Couldn\'t read a total from that image. Try again or add it manually.',
                style: GoogleFonts.syne(
                    fontSize: 13, color: Colors.white)),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      _showAddTransaction(context, palette, prefilledAmount: total);
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong reading that image.',
                style: GoogleFonts.syne(
                    fontSize: 13, color: Colors.white)),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final notifCount = _upcomingEvents.length;

    return Scaffold(
      backgroundColor: palette.bg,
      floatingActionButton: _AskFAB(palette: palette),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          // Tab 0 — Home
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: CustomScrollView(
                slivers: [
                  // Top bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: palette.ink,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: CustomPaint(
                              painter: _RRPainter(
                                leftColor: palette.bg2,
                                rightColor: palette.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'LEDG',
                                  style: GoogleFonts.syne(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: palette.ink,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'RR',
                                  style: GoogleFonts.syne(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: palette.accent,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Add Transaction
                          Material(
                            color: palette.accent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () =>
                                  _showAddTransaction(context, palette),
                              child: Container(
                                width: 40, height: 40,
                                child: Icon(Icons.add_rounded,
                                    color: palette.accentFg, size: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Scan receipt
                          Material(
                            color: palette.bg2,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () =>
                                  _scanReceipt(context, palette),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: palette.border),
                                ),
                                child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: palette.ink,
                                    size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Notifications with count badge
                          Material(
                            color: palette.bg2,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () =>
                                  _showNotifications(context, palette),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: palette.border),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                        Icons.notifications_outlined,
                                        color: palette.ink,
                                        size: 18),
                                    if (notifCount > 0)
                                      Positioned(
                                        top: -4, right: -4,
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(3),
                                          constraints:
                                              const BoxConstraints(
                                                  minWidth: 16,
                                                  minHeight: 16),
                                          decoration: BoxDecoration(
                                            color: palette.accent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: palette.bg,
                                                width: 1.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              notifCount > 9
                                                  ? '9+'
                                                  : '$notifCount',
                                              style: GoogleFonts.syne(
                                                fontSize: 9,
                                                fontWeight:
                                                    FontWeight.w800,
                                                color:
                                                    palette.accentFg,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Greeting
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting, $_userName',
                            style: GoogleFonts.syne(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: palette.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Here is your truth for today.',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Daily sentence card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.isDark
                              ? palette.bg2
                              : palette.ink,
                          borderRadius: BorderRadius.circular(20),
                          border: palette.isDark
                              ? Border.all(color: palette.border)
                              : null,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (_isStable
                                            ? palette.accent
                                            : const Color(0xFFB5446E))
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    _isStable ? 'Stable' : 'Attention',
                                    style: GoogleFonts.syne(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _isStable
                                          ? palette.accent
                                          : const Color(0xFFB5446E),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text('Daily sentence',
                                    style: GoogleFonts.syne(
                                        fontSize: 10,
                                        color: palette.isDark
                                            ? palette.inkMuted
                                            : Colors.white38)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '"$_dailySentence"',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                color: palette.isDark
                                    ? palette.ink
                                    : Colors.white,
                                height: 1.55,
                              ),
                            ),
                            if (_currentStreak > 0) ...[
                              const SizedBox(height: 12),
                              Text(
                                _currentStreak == 1
                                    ? 'Showed up today.'
                                    : '$_currentStreak days in a row.',
                                style: GoogleFonts.syne(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: palette.isDark
                                      ? palette.inkMuted
                                      : Colors.white54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stat cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'True Balance',
                              value: _formatAmount(_trueBalance),
                              sublabel: 'all time',
                              iconType: 'balance',
                              palette: palette,
                              isPositive: _trueBalance >= 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'This Month',
                              value: _formatAmount(_monthlyIncome),
                              sublabel: 'income',
                              iconType: 'memory',
                              palette: palette,
                              isPositive: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'Spent',
                              value: _formatAmount(_monthlyExpense),
                              sublabel: 'this month',
                              iconType: 'spendlist',
                              palette: palette,
                              isPositive: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Feature grid header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Text('Explore',
                          style: GoogleFonts.syne(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: palette.ink)),
                    ),
                  ),

                  // Feature grid — 2 per row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _FeatureGridCard(
                                  palette: palette,
                                  icon: CustomPaint(
                                    painter: _GhostHomePainter(
                                        color: palette.accent),
                                  ),
                                  title: 'Ghost Money',
                                  subtitle: 'Recurring patterns',
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const GhostScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FeatureGridCard(
                                  palette: palette,
                                  icon: Icon(
                                      Icons.auto_stories_rounded,
                                      color: palette.accent,
                                      size: 22),
                                  title: 'Money Memory',
                                  subtitle: 'Daily journal',
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const MemoryScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _FeatureGridCard(
                                  palette: palette,
                                  icon: CustomPaint(
                                    painter: _JarHomePainter(
                                        color: palette.accent),
                                  ),
                                  title: 'Savings Jars',
                                  subtitle: 'Deposit, withdraw',
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PiggyBankScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FeatureGridCard(
                                  palette: palette,
                                  icon: CustomPaint(
                                    painter: _DuesHomePainter(
                                        color: palette.accent),
                                  ),
                                  title: 'Dues Tracker',
                                  subtitle: 'Settle up',
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const DuesScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent transactions header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Row(
                        children: [
                          Text('Recent transactions',
                              style: GoogleFonts.syne(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HistoryScreen()),
                            ),
                            child: Text('See all',
                                style: GoogleFonts.syne(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: palette.accent)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Transactions
                  StreamBuilder(
                    stream:
                        _transactionService.getTransactionsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: palette.accent,
                                  strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                24, 20, 24, 0),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: palette.card,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                    color: palette.border),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                      Icons.receipt_long_outlined,
                                      color: palette.inkMuted,
                                      size: 40),
                                  const SizedBox(height: 12),
                                  Text('No transactions yet',
                                      style: GoogleFonts.syne(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: palette.ink)),
                                  const SizedBox(height: 6),
                                  Text(
                                      'Tap the + button to get started.',
                                      style: GoogleFonts.syne(
                                          fontSize: 13,
                                          color: palette.inkMuted),
                                      textAlign:
                                          TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final docs =
                          snapshot.data!.docs.take(10).toList();

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final doc = docs[i];
                            final data = doc.data()
                                as Map<String, dynamic>;
                            final isIncome =
                                data['type'] == 'income';
                            final amount =
                                (data['amount'] as num).toDouble();
                            final date =
                                (data['date'] as dynamic).toDate()
                                    as DateTime;

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  24, 10, 24, 0),
                              child: Dismissible(
                                key: Key(doc.id),
                                direction:
                                    DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(
                                      left: 60),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFE53935),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                      right: 20),
                                  child: const Icon(
                                      Icons
                                          .delete_outline_rounded,
                                      color: Colors.white,
                                      size: 22),
                                ),
                                confirmDismiss: (_) async {
                                  bool confirmed = false;
                                  await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: palette.card,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20)),
                                      title: Text(
                                          'Delete transaction?',
                                          style: GoogleFonts.syne(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: palette.ink)),
                                      content: Text(
                                          'This cannot be undone.',
                                          style: GoogleFonts.syne(
                                              fontSize: 13,
                                              color:
                                                  palette.inkMuted)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancel',
                                              style: GoogleFonts.syne(
                                                  fontSize: 13,
                                                  color: palette
                                                      .inkMuted)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            confirmed = true;
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete',
                                              style: GoogleFonts.syne(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: const Color(
                                                      0xFFE53935))),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed) {
                                    await _transactionService
                                        .deleteTransaction(doc.id);
                                    _loadData();
                                  }
                                  return confirmed;
                                },
                                child: GestureDetector(
                                  onTap: () =>
                                      _showEditTransaction(
                                          context, palette, doc),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: palette.card,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                          color: palette.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42, height: 42,
                                          decoration: BoxDecoration(
                                            color: isIncome
                                                ? palette.accent
                                                    .withOpacity(
                                                        0.12)
                                                : const Color(
                                                        0xFFB5446E)
                                                    .withOpacity(
                                                        0.1),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                          ),
                                          child: Icon(
                                            isIncome
                                                ? Icons
                                                    .arrow_downward_rounded
                                                : Icons
                                                    .arrow_upward_rounded,
                                            color: isIncome
                                                ? palette.accent
                                                : const Color(
                                                    0xFFB5446E),
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                  data['title'] ??
                                                      '',
                                                  style: GoogleFonts
                                                      .syne(
                                                          fontSize:
                                                              13,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                          color: palette
                                                              .ink)),
                                              const SizedBox(
                                                  height: 2),
                                              Text(
                                                '${data['category']} · ${date.day}/${date.month}/${date.year}',
                                                style: GoogleFonts
                                                    .syne(
                                                        fontSize: 11,
                                                        color: palette
                                                            .inkMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isIncome ? '+' : '-'}${_formatAmount(amount)}',
                                              style:
                                                  GoogleFonts.syne(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: isIncome
                                                    ? palette.accent
                                                    : const Color(
                                                        0xFFB5446E),
                                              ),
                                            ),
                                            Text('tap to edit',
                                                style: GoogleFonts
                                                    .syne(
                                                        fontSize: 9,
                                                        color: palette
                                                            .inkMuted)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: docs.length,
                        ),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),

          // Tab 1 — Calendar
          const CalendarScreen(),

          // Tab 2 — Spend List
          const SpendListScreen(),

          // Tab 3 — Statistics
          StatisticsScreen(key: ValueKey(_statsRefreshKey)),

          // Tab 4 — Learn Finance
          const LearnScreen(),

          // Tab 5 — Profile
          const ProfileScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: palette.card,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentNavIndex == 0,
                  palette: palette,
                  onTap: () {
                    setState(() => _currentNavIndex = 0);
                    _loadData();
                  },
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  isActive: _currentNavIndex == 1,
                  palette: palette,
                  onTap: () =>
                      setState(() => _currentNavIndex = 1),
                ),
                _NavItem(
                  icon: Icons.checklist_rounded,
                  label: 'Spend List',
                  isActive: _currentNavIndex == 2,
                  palette: palette,
                  onTap: () =>
                      setState(() => _currentNavIndex = 2),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistics',
                  isActive: _currentNavIndex == 3,
                  palette: palette,
                  onTap: () {
                    setState(() {
                      _currentNavIndex = 3;
                      _statsRefreshKey++;
                    });
                  },
                ),
                _NavItem(
                  icon: Icons.school_rounded,
                  label: 'Learn',
                  isActive: _currentNavIndex == 4,
                  palette: palette,
                  onTap: () =>
                      setState(() => _currentNavIndex = 4),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: _currentNavIndex == 5,
                  palette: palette,
                  onTap: () =>
                      setState(() => _currentNavIndex = 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTransaction(
      BuildContext context, LedgrrPalette palette,
      {double? prefilledAmount}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTransactionSheet(
        palette: palette,
        onAdded: _loadData,
        prefilledAmount: prefilledAmount,
      ),
    );
  }

  void _showEditTransaction(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTransactionSheet(
        palette: palette,
        onAdded: _loadData,
        existingDoc: doc,
      ),
    );
  }
}

// ─── FEATURE GRID CARD ─────────────────────────────────────────────────────

class _FeatureGridCard extends StatelessWidget {
  final LedgrrPalette palette;
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureGridCard({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.bg2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: palette.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: icon,
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.ink)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.syne(
                      fontSize: 10,
                      color: palette.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ADD / EDIT TRANSACTION SHEET ──────────────────────────────────────────

class _AddTransactionSheet extends StatefulWidget {
  final LedgrrPalette palette;
  final VoidCallback onAdded;
  final DocumentSnapshot? existingDoc;
  final double? prefilledAmount;

  const _AddTransactionSheet({
    required this.palette,
    required this.onAdded,
    this.existingDoc,
    this.prefilledAmount,
  });

  @override
  State<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState
    extends State<_AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _transactionService = TransactionService();
  String _type = 'expense';
  String _selectedCategory = 'food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _expenseCategories = [
    {'id': 'food', 'name': 'Food'},
    {'id': 'transport', 'name': 'Transport'},
    {'id': 'shopping', 'name': 'Shopping'},
    {'id': 'health', 'name': 'Health'},
    {'id': 'utilities', 'name': 'Utilities'},
    {'id': 'rent', 'name': 'Rent'},
    {'id': 'education', 'name': 'Education'},
    {'id': 'entertainment', 'name': 'Fun'},
    {'id': 'subscriptions', 'name': 'Subscriptions'},
    {'id': 'medical', 'name': 'Medical'},
    {'id': 'fuel', 'name': 'Fuel'},
    {'id': 'groceries', 'name': 'Groceries'},
    {'id': 'clothing', 'name': 'Clothing'},
    {'id': 'personalcare', 'name': 'Self Care'},
    {'id': 'dining', 'name': 'Dining Out'},
    {'id': 'coffee', 'name': 'Coffee'},
    {'id': 'social', 'name': 'Social'},
    {'id': 'electricity', 'name': 'Electricity'},
    {'id': 'water', 'name': 'Water'},
    {'id': 'internet', 'name': 'Internet'},
    {'id': 'mobile', 'name': 'Mobile'},
    {'id': 'savings', 'name': 'Savings'},
    {'id': 'other_expense', 'name': 'Other'},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'id': 'salary', 'name': 'Salary'},
    {'id': 'freelance', 'name': 'Freelance'},
    {'id': 'allowance', 'name': 'Allowance'},
    {'id': 'gift', 'name': 'Gift'},
    {'id': 'investment', 'name': 'Investment'},
    {'id': 'refund', 'name': 'Refund'},
    {'id': 'business', 'name': 'Business'},
    {'id': 'other_income', 'name': 'Other'},
  ];

  List<Map<String, dynamic>> get _categories =>
      _type == 'expense'
          ? _expenseCategories
          : _incomeCategories;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledAmount != null) {
      _amountController.text =
          widget.prefilledAmount!.toStringAsFixed(0);
    }
    if (widget.existingDoc != null) {
      final data =
          widget.existingDoc!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _amountController.text =
          (data['amount'] as num?)?.toString() ?? '';
      _noteController.text = data['note'] ?? '';
      _type = data['type'] ?? 'expense';
      _selectedCategory = data['category'] ?? 'food';
      _selectedDate =
          (data['date'] as Timestamp?)?.toDate() ??
              DateTime.now();
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_amountController.text.trim().isEmpty) return;
    final amount =
        double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _isLoading = true);
    try {
      if (widget.existingDoc != null) {
        await _transactionService.updateTransaction(
          transactionId: widget.existingDoc!.id,
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          type: _type,
          date: _selectedDate,
          note: _noteController.text.trim(),
        );
      } else {
        await _transactionService.addTransaction(
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          type: _type,
          date: _selectedDate,
          note: _noteController.text.trim(),
        );
      }
      widget.onAdded();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final isEditing = widget.existingDoc != null;

    return Container(
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
                isEditing
                    ? 'Edit transaction'
                    : 'Add transaction',
                style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                    letterSpacing: -0.5)),
            if (widget.prefilledAmount != null && !isEditing) ...[
              const SizedBox(height: 6),
              Text('Amount pulled from your receipt — check it looks right.',
                  style: GoogleFonts.syne(
                      fontSize: 12, color: palette.inkMuted)),
            ],
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: palette.bg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: ['expense', 'income'].map((t) {
                  final isSelected = _type == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = t;
                        _selectedCategory =
                            t == 'expense' ? 'food' : 'salary';
                      }),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? palette.accent
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            t == 'expense'
                                ? 'Expense'
                                : 'Income',
                            style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? palette.accentFg
                                    : palette.inkMuted),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _sheetField(
                controller: _titleController,
                hint: 'What was this for?',
                label: 'Title',
                palette: palette),
            const SizedBox(height: 12),
            _sheetField(
                controller: _amountController,
                hint: '0.00',
                label: 'Amount (₹)',
                palette: palette,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Text('Category',
                style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.inkMuted,
                    letterSpacing: 0.05)),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected =
                      _selectedCategory == cat['id'];
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _selectedCategory = cat['id']),
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.accent
                            : palette.bg2,
                        borderRadius:
                            BorderRadius.circular(100),
                        border: Border.all(
                            color: isSelected
                                ? palette.accent
                                : palette.border),
                      ),
                      child: Text(cat['name'],
                          style: GoogleFonts.syne(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? palette.accentFg
                                  : palette.inkMuted)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: palette.accent, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: GoogleFonts.syne(
                          fontSize: 14, color: palette.ink),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _sheetField(
                controller: _noteController,
                hint: 'Add a note (optional)',
                label: 'Note',
                palette: palette),
            const SizedBox(height: 24),
            Material(
              color: palette.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isLoading ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.accentFg))
                        : Text(
                            isEditing
                                ? 'Save changes'
                                : 'Save transaction',
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                color: palette.accentFg)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required LedgrrPalette palette,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.syne(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.inkMuted,
                letterSpacing: 0.05)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: palette.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.syne(
                fontSize: 15, color: palette.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.syne(
                  fontSize: 14, color: palette.inkMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SENTENCE CHIP ─────────────────────────────────────────────────────────

class _SentenceChip extends StatelessWidget {
  final String label;
  final String value;
  final LedgrrPalette palette;

  const _SentenceChip({
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: palette.isDark
              ? palette.border.withOpacity(0.3)
              : Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.syne(
                    fontSize: 9,
                    color: palette.isDark
                        ? palette.inkMuted
                        : Colors.white54)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.accent)),
          ],
        ),
      ),
    );
  }
}

// ─── STAT CARD ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final String iconType;
  final LedgrrPalette palette;
  final bool isPositive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.iconType,
    required this.palette,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28, height: 28,
            child: CustomPaint(
              painter: _IconPainter(
                type: iconType,
                color: isPositive
                    ? palette.accent
                    : const Color(0xFFB5446E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.syne(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isPositive
                      ? palette.ink
                      : const Color(0xFFB5446E),
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.syne(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: palette.ink)),
          Text(sublabel,
              style: GoogleFonts.syne(
                  fontSize: 9, color: palette.inkMuted)),
        ],
      ),
    );
  }
}

// ─── NAV ITEM ──────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final LedgrrPalette palette;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? palette.accent.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(icon,
                size: 20,
                color: isActive
                    ? palette.accent
                    : palette.inkMuted),
          ),
          Text(label,
              style: GoogleFonts.syne(
                  fontSize: 8,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isActive
                      ? palette.accent
                      : palette.inkMuted)),
        ],
      ),
    );
  }
}

// ─── ICON PAINTER ──────────────────────────────────────────────────────────

class _IconPainter extends CustomPainter {
  final String type;
  final Color color;

  const _IconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (type) {
      case 'balance':
        canvas.drawLine(
            Offset(cx, cy - 11), Offset(cx, cy + 11), p);
        canvas.drawLine(Offset(cx - 10, cy - 1),
            Offset(cx + 10, cy - 1), p);
        canvas.drawLine(Offset(cx - 10, cy - 1),
            Offset(cx - 10, cy + 5), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx - 10, cy + 8),
                    width: 11, height: 4),
                const Radius.circular(1.5)),
            pf);
        canvas.drawLine(Offset(cx + 10, cy - 1),
            Offset(cx + 10, cy - 7), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx + 10, cy - 10),
                    width: 11, height: 4),
                const Radius.circular(1.5)),
            pf);
        break;

      case 'memory':
        canvas.drawLine(
            Offset(cx, cy - 10), Offset(cx, cy + 10), p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 13, cy - 10, cx, cy + 10),
                const Radius.circular(2)),
            p);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx, cy - 10, cx + 13, cy + 10),
                const Radius.circular(2)),
            p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx - 10, cy - 4),
            Offset(cx - 3, cy - 4), lp2);
        canvas.drawLine(
            Offset(cx - 10, cy), Offset(cx - 3, cy), lp2);
        canvas.drawLine(Offset(cx - 10, cy + 4),
            Offset(cx - 3, cy + 4), lp2);
        canvas.drawLine(Offset(cx + 3, cy - 4),
            Offset(cx + 10, cy - 4), lp2);
        canvas.drawLine(
            Offset(cx + 3, cy), Offset(cx + 10, cy), lp2);
        break;

      case 'spendlist':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(cx, cy),
                    width: 22, height: 24),
                const Radius.circular(4)),
            p);
        final lp2 = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        final c1 = Path();
        c1.moveTo(cx - 7, cy - 5);
        c1.lineTo(cx - 5, cy - 3);
        c1.lineTo(cx - 1, cy - 8);
        canvas.drawPath(c1, lp2);
        canvas.drawLine(Offset(cx + 1, cy - 5),
            Offset(cx + 7, cy - 5), lp2);
        final c2 = Path();
        c2.moveTo(cx - 7, cy + 1);
        c2.lineTo(cx - 5, cy + 3);
        c2.lineTo(cx - 1, cy - 2);
        canvas.drawPath(c2, lp2);
        canvas.drawLine(Offset(cx + 1, cy + 1),
            Offset(cx + 7, cy + 1), lp2);
        canvas.drawCircle(
            Offset(cx - 6, cy + 7), 2,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
        canvas.drawLine(Offset(cx + 1, cy + 7),
            Offset(cx + 7, cy + 7), lp2);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── RR PAINTER ────────────────────────────────────────────────────────────

class _RRPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _RRPainter(
      {required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 11, cy + 11);
    lp.lineTo(cx - 11, cy - 5);
    lp.quadraticBezierTo(cx - 11, cy - 11, cx - 6, cy - 11);
    lp.quadraticBezierTo(cx - 1, cy - 11, cx - 1, cy - 5);
    lp.quadraticBezierTo(cx - 1, cy + 1, cx - 6, cy + 1);
    lp.lineTo(cx - 2, cy + 11);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 11, cy + 11);
    rp.lineTo(cx + 11, cy - 5);
    rp.quadraticBezierTo(cx + 11, cy - 11, cx + 6, cy - 11);
    rp.quadraticBezierTo(cx + 1, cy - 11, cx + 1, cy - 5);
    rp.quadraticBezierTo(cx + 1, cy + 1, cx + 6, cy + 1);
    rp.lineTo(cx + 2, cy + 11);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── GHOST HOME PAINTER ────────────────────────────────────────────────────

class _GhostHomePainter extends CustomPainter {
  final Color color;
  const _GhostHomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path();
    path.moveTo(cx - 10, cy + 10);
    path.lineTo(cx - 10, cy - 2);
    path.quadraticBezierTo(cx - 10, cy - 12, cx, cy - 12);
    path.quadraticBezierTo(cx + 10, cy - 12, cx + 10, cy - 2);
    path.lineTo(cx + 10, cy + 10);
    path.lineTo(cx + 5, cy + 6);
    path.lineTo(cx, cy + 10);
    path.lineTo(cx - 5, cy + 6);
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(cx - 3, cy - 2), 1.8, pf);
    canvas.drawCircle(Offset(cx + 3, cy - 2), 1.8, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── JAR HOME PAINTER ──────────────────────────────────────────────────────

class _JarHomePainter extends CustomPainter {
  final Color color;
  const _JarHomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy - 11), width: 15, height: 4),
        const Radius.circular(1.2),
      ),
      pf,
    );

    final body = Path();
    body.moveTo(cx - 5, cy - 9);
    body.lineTo(cx - 5, cy - 5);
    body.quadraticBezierTo(cx - 11, cy - 3, cx - 11, cy + 4);
    body.lineTo(cx - 11, cy + 8);
    body.quadraticBezierTo(cx - 11, cy + 12, cx - 7, cy + 12);
    body.lineTo(cx + 7, cy + 12);
    body.quadraticBezierTo(cx + 11, cy + 12, cx + 11, cy + 8);
    body.lineTo(cx + 11, cy + 4);
    body.quadraticBezierTo(cx + 11, cy - 3, cx + 5, cy - 5);
    body.lineTo(cx + 5, cy - 9);
    body.close();
    canvas.drawPath(body, p);

    canvas.drawLine(
        Offset(cx - 8, cy + 3), Offset(cx + 8, cy + 3), fillLine);

    canvas.drawCircle(Offset(cx - 3, cy - 1), 1.4, pf);
    canvas.drawCircle(Offset(cx + 4, cy + 0.5), 1.4, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── DUES HOME PAINTER ─────────────────────────────────────────────────────

class _DuesHomePainter extends CustomPainter {
  final Color color;
  const _DuesHomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final top = Path();
    top.moveTo(cx - 8, cy - 3);
    top.quadraticBezierTo(cx, cy - 10, cx + 8, cy - 3);
    canvas.drawPath(top, p);
    final topHead = Path();
    topHead.moveTo(cx + 8, cy - 3);
    topHead.lineTo(cx + 4, cy - 5);
    topHead.moveTo(cx + 8, cy - 3);
    topHead.lineTo(cx + 5, cy + 0.5);
    canvas.drawPath(topHead, p);

    final bottom = Path();
    bottom.moveTo(cx + 8, cy + 3);
    bottom.quadraticBezierTo(cx, cy + 10, cx - 8, cy + 3);
    canvas.drawPath(bottom, p);
    final bottomHead = Path();
    bottomHead.moveTo(cx - 8, cy + 3);
    bottomHead.lineTo(cx - 4, cy + 5);
    bottomHead.moveTo(cx - 8, cy + 3);
    bottomHead.lineTo(cx - 5, cy - 0.5);
    canvas.drawPath(bottomHead, p);

    canvas.drawCircle(Offset(cx - 8, cy - 3), 1.6, pf);
    canvas.drawCircle(Offset(cx + 8, cy + 3), 1.6, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── ASK FAB ───────────────────────────────────────────────────────────────

class _AskFAB extends StatelessWidget {
  final LedgrrPalette palette;
  const _AskFAB({required this.palette});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                color: palette.bg,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
              ),
              child: const AskScreen(),
            ),
          ),
        );
      },
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: palette.ink,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: palette.ink.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _MiniRRPainter(
            leftColor: palette.bg2,
            rightColor: palette.accent,
          ),
        ),
      ),
    );
  }
}

// ─── MINI RR PAINTER ───────────────────────────────────────────────────────

class _MiniRRPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  const _MiniRRPainter(
      {required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final left = Paint()
      ..color = leftColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final right = Paint()
      ..color = rightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final lp = Path();
    lp.moveTo(cx - 11, cy + 11);
    lp.lineTo(cx - 11, cy - 5);
    lp.quadraticBezierTo(cx - 11, cy - 11, cx - 6, cy - 11);
    lp.quadraticBezierTo(cx - 1, cy - 11, cx - 1, cy - 5);
    lp.quadraticBezierTo(cx - 1, cy + 1, cx - 6, cy + 1);
    lp.lineTo(cx - 2, cy + 11);
    canvas.drawPath(lp, left);

    final rp = Path();
    rp.moveTo(cx + 11, cy + 11);
    rp.lineTo(cx + 11, cy - 5);
    rp.quadraticBezierTo(cx + 11, cy - 11, cx + 6, cy - 11);
    rp.quadraticBezierTo(cx + 1, cy - 11, cx + 1, cy - 5);
    rp.quadraticBezierTo(cx + 1, cy + 1, cx + 6, cy + 1);
    rp.lineTo(cx + 2, cy + 11);
    canvas.drawPath(rp, right);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}