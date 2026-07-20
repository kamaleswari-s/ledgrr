import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class GhostScreen extends StatefulWidget {
  const GhostScreen({super.key});

  @override
  State<GhostScreen> createState() => _GhostScreenState();
}

class _GhostScreenState extends State<GhostScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;
  List<_GhostItem> _ghosts = [];
  double _totalGhostAmount = 0;

  @override
  void initState() {
    super.initState();
    _scanForGhosts();
  }

  Future<void> _scanForGhosts() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('transactions')
          .where('type', isEqualTo: 'expense')
          .orderBy('date', descending: true)
          .get();

      final docs = snapshot.docs;
      final ghosts = <_GhostItem>[];
      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (final doc in docs) {
        final data = doc.data();
        final title = (data['title'] as String).toLowerCase().trim();
        final category = data['category'] as String;
        final isSubscriptionCategory = [
          'subscriptions', 'internet', 'mobile', 'utilities',
          'electricity', 'water',
        ].contains(category);

        String key = title;
        bool found = false;
        for (final existingKey in grouped.keys) {
          if (_isSimilar(title, existingKey)) {
            key = existingKey;
            found = true;
            break;
          }
        }
        if (!found) grouped[key] = [];
        grouped[key]!.add({
          ...data, 'id': doc.id, 'isSubscription': isSubscriptionCategory,
        });
      }

      for (final entry in grouped.entries) {
        final transactions = entry.value;

        if (transactions.length >= 2) {
          final amounts = transactions
              .map((t) => (t['amount'] as num).toDouble())
              .toList();
          final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;
          final isConsistent =
              amounts.every((a) => (a - avgAmount).abs() < avgAmount * 0.2);

          if (isConsistent) {
            final lastDate =
                (transactions.first['date'] as Timestamp).toDate();
            final daysSinceLast =
                DateTime.now().difference(lastDate).inDays;

            String ghostType = 'Recurring expense';
            String reason =
                'This charge appears ${transactions.length} times in your history.';

            if (transactions.first['isSubscription'] == true) {
              ghostType = 'Subscription detected';
              reason =
                  'Appears to be a recurring subscription. Check if you still use this.';
            }
            if (daysSinceLast > 25 && daysSinceLast < 45) {
              ghostType = 'Monthly recurring';
              reason =
                  'This charge appears monthly. Last charged $daysSinceLast days ago.';
            }

            ghosts.add(_GhostItem(
              title: _capitalize(entry.key),
              amount: avgAmount,
              occurrences: transactions.length,
              lastSeen: lastDate,
              ghostType: ghostType,
              reason: reason,
              category: transactions.first['category'] as String,
            ));
          }
        }

        if (transactions.length == 1) {
          final data = transactions.first;
          final amount = (data['amount'] as num).toDouble();
          final category = data['category'] as String;
          final date = (data['date'] as Timestamp).toDate();

          if (category == 'subscriptions' ||
              category == 'internet' ||
              category == 'mobile') {
            ghosts.add(_GhostItem(
              title: _capitalize(entry.key),
              amount: amount,
              occurrences: 1,
              lastSeen: date,
              ghostType: 'Possible subscription',
              reason:
                  'Logged under ${_capitalize(category)}. Verify if this is recurring.',
              category: category,
            ));
          }
        }
      }

      ghosts.sort((a, b) => b.amount.compareTo(a.amount));
      final total = ghosts.fold(0.0, (sum, g) => sum + g.amount);

      if (mounted) {
        setState(() {
          _ghosts = ghosts;
          _totalGhostAmount = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isSimilar(String a, String b) {
    if (a == b) return true;
    if (a.contains(b) || b.contains(a)) return true;
    if (a.length >= 4 && b.length >= 4) {
      return a.substring(0, 4) == b.substring(0, 4);
    }
    return false;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _timeAgo(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 30) return '$days days ago';
    if (days < 60) return '1 month ago';
    return '${(days / 30).floor()} months ago';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ghost Money',
                          style: GoogleFonts.syne(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              color: palette.ink, letterSpacing: -0.5)),
                      Text('Detector',
                          style: GoogleFonts.syne(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              color: palette.accent, letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _scanForGhosts,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.refresh_rounded,
                                color: palette.accent, size: 16),
                            const SizedBox(width: 6),
                            Text('Rescan',
                                style: GoogleFonts.syne(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: palette.accent)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Recurring charges and forgotten subscriptions found in your transactions.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 14, fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),

            const SizedBox(height: 16),

            if (!_isLoading && _ghosts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.isDark ? palette.card : palette.ink,
                    borderRadius: BorderRadius.circular(16),
                    border: palette.isDark
                        ? Border.all(color: palette.border)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total ghost money found',
                                style: GoogleFonts.syne(
                                    fontSize: 12,
                                    color: palette.isDark
                                        ? palette.inkMuted
                                        : Colors.white60)),
                            const SizedBox(height: 4),
                            Text(_formatAmount(_totalGhostAmount),
                                style: GoogleFonts.syne(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: palette.accent,
                                    letterSpacing: -1)),
                            Text(
                              'across ${_ghosts.length} ${_ghosts.length == 1 ? 'pattern' : 'patterns'}',
                              style: GoogleFonts.syne(
                                  fontSize: 12,
                                  color: palette.isDark
                                      ? palette.inkMuted
                                      : Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: palette.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(
                          painter: _GhostIconPainter(color: palette.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: palette.accent, strokeWidth: 2),
                          const SizedBox(height: 16),
                          Text('Scanning your transactions...',
                              style: GoogleFonts.syne(
                                  fontSize: 13, color: palette.inkMuted)),
                        ],
                      ),
                    )
                  : _ghosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 56, height: 56,
                                child: CustomPaint(
                                  painter: _GhostIconPainter(
                                      color: palette.inkMuted.withOpacity(0.3)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('No ghosts found',
                                  style: GoogleFonts.syne(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: palette.ink)),
                              const SizedBox(height: 8),
                              Text(
                                'Add more transactions and\nLEDGRR will find recurring patterns.',
                                style: GoogleFonts.syne(
                                    fontSize: 13, color: palette.inkMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: _ghosts.length,
                          itemBuilder: (context, i) {
                            final ghost = _ghosts[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: palette.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: palette.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: palette.accent
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Text(ghost.ghostType,
                                              style: GoogleFonts.syne(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: palette.accent)),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatAmount(ghost.amount),
                                          style: GoogleFonts.syne(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: palette.ink,
                                              letterSpacing: -0.5),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(ghost.title,
                                        style: GoogleFonts.syne(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: palette.ink)),
                                    const SizedBox(height: 4),
                                    Text(ghost.reason,
                                        style: GoogleFonts.syne(
                                            fontSize: 12,
                                            color: palette.inkMuted,
                                            height: 1.5)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded,
                                            size: 12, color: palette.inkMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                            'Last seen: ${_timeAgo(ghost.lastSeen)}',
                                            style: GoogleFonts.syne(
                                                fontSize: 11,
                                                color: palette.inkMuted)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.repeat_rounded,
                                            size: 12, color: palette.inkMuted),
                                        const SizedBox(width: 4),
                                        Text('${ghost.occurrences}x found',
                                            style: GoogleFonts.syne(
                                                fontSize: 11,
                                                color: palette.inkMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostItem {
  final String title;
  final double amount;
  final int occurrences;
  final DateTime lastSeen;
  final String ghostType;
  final String reason;
  final String category;

  const _GhostItem({
    required this.title,
    required this.amount,
    required this.occurrences,
    required this.lastSeen,
    required this.ghostType,
    required this.reason,
    required this.category,
  });
}

class _GhostIconPainter extends CustomPainter {
  final Color color;
  const _GhostIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path();
    path.moveTo(cx - 14, cy + 14);
    path.lineTo(cx - 14, cy - 4);
    path.quadraticBezierTo(cx - 14, cy - 18, cx, cy - 18);
    path.quadraticBezierTo(cx + 14, cy - 18, cx + 14, cy - 4);
    path.lineTo(cx + 14, cy + 14);
    path.lineTo(cx + 7, cy + 8);
    path.lineTo(cx, cy + 14);
    path.lineTo(cx - 7, cy + 8);
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(cx - 5, cy - 4), 2.5, pf);
    canvas.drawCircle(Offset(cx + 5, cy - 4), 2.5, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}