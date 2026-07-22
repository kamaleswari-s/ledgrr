import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _transactionService = TransactionService();
  final _noteController = TextEditingController();
  bool _isGenerating = false;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    _autoWriteTodayIfMissing();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _dateKeyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Checks if today already has a memory entry. If not, writes one
  /// silently — this is what makes the journal feel automatic instead
  /// of requiring a manual tap every day.
  Future<void> _autoWriteTodayIfMissing() async {
    final today = DateTime.now();
    final dateKey = _dateKeyFor(today);

    final existing = await _db
        .collection('users')
        .doc(_uid)
        .collection('memory')
        .doc(dateKey)
        .get();

    if (existing.exists) return;

    await _generateAndSaveEntry(today);
  }

  /// Builds a sentence describing THIS SPECIFIC DAY, using only that
  /// day's own transactions — not the whole month.
  Future<String> _generateDailySentence(DateTime date) async {
    try {
      final dayData = await _transactionService.getDailySummary(date);
      final income = dayData['income'] ?? 0.0;
      final expense = dayData['expense'] ?? 0.0;

      if (income == 0 && expense == 0) {
        return 'No transactions logged today.';
      }

      final balance = await _transactionService.getTrueBalance();
      final categorySpending =
          await _transactionService.getCategorySpending(
        date.year, date.month,
      );

      if (expense > 0 && income == 0) {
        final topCategory = categorySpending.isNotEmpty
            ? categorySpending.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
            : null;
        if (topCategory != null) {
          return 'Spent ₹${expense.toStringAsFixed(0)} today, mostly on $topCategory. True Balance stands at ₹${balance.toStringAsFixed(0)}.';
        }
        return 'Spent ₹${expense.toStringAsFixed(0)} today. True Balance stands at ₹${balance.toStringAsFixed(0)}.';
      }

      if (income > 0 && expense == 0) {
        return 'Added ₹${income.toStringAsFixed(0)} in income today. True Balance stands at ₹${balance.toStringAsFixed(0)}.';
      }

      final net = income - expense;
      if (net >= 0) {
        return 'Earned ₹${income.toStringAsFixed(0)} and spent ₹${expense.toStringAsFixed(0)} today — net positive. True Balance stands at ₹${balance.toStringAsFixed(0)}.';
      }
      return 'Spent ₹${expense.toStringAsFixed(0)} against ₹${income.toStringAsFixed(0)} earned today. True Balance stands at ₹${balance.toStringAsFixed(0)}.';
    } catch (e) {
      return 'Keep tracking your transactions and LEDGRR will write your financial story here.';
    }
  }

  Future<void> _generateAndSaveEntry(DateTime date) async {
    if (mounted) setState(() => _isGenerating = true);

    try {
      final sentence = await _generateDailySentence(date);
      final dateKey = _dateKeyFor(date);

      await _db
          .collection('users')
          .doc(_uid)
          .collection('memory')
          .doc(dateKey)
          .set({
        'date': Timestamp.fromDate(date),
        'dateKey': dateKey,
        'autoSentence': sentence,
        'note': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // silently fail
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveNote(String dateKey, String note) async {
    setState(() => _isSavingNote = true);
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('memory')
          .doc(dateKey)
          .set({'note': note}, SetOptions(merge: true));
    } finally {
      if (mounted) setState(() => _isSavingNote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Money',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('Memory',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.accent,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isGenerating
                          ? null
                          : () => _generateAndSaveEntry(today),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: _isGenerating
                            ? SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: palette.accentFg))
                            : Row(
                                children: [
                                  Icon(Icons.refresh_rounded,
                                      color: palette.accentFg, size: 14),
                                  const SizedBox(width: 6),
                                  Text('Refresh today',
                                      style: GoogleFonts.syne(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: palette.accentFg)),
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
                'Your financial journal. Written automatically each day, personalised by you.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('users')
                    .doc(_uid)
                    .collection('memory')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: palette.accent, strokeWidth: 2),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_outlined,
                              color: palette.inkMuted, size: 48),
                          const SizedBox(height: 16),
                          Text('Writing your first entry...',
                              style: GoogleFonts.syne(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          const SizedBox(height: 8),
                          Text(
                            'LEDGRR writes a new entry\nautomatically every day.',
                            style: GoogleFonts.syne(
                                fontSize: 13, color: palette.inkMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final date =
                          (data['date'] as Timestamp).toDate();
                      final autoSentence =
                          data['autoSentence'] as String? ?? '';
                      final note = data['note'] as String? ?? '';
                      final dateKey = data['dateKey'] as String? ??
                          _dateKeyFor(date);
                      final isToday = date.year == today.year &&
                          date.month == today.month &&
                          date.day == today.day;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _MemoryCard(
                          date: date,
                          autoSentence: autoSentence,
                          note: note,
                          dateKey: dateKey,
                          isToday: isToday,
                          palette: palette,
                          formatDate: _formatDate,
                          formatShortDate: _formatShortDate,
                          onSaveNote: _saveNote,
                        ),
                      );
                    },
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

// ─── MEMORY CARD ───────────────────────────────────────────────────────────

class _MemoryCard extends StatefulWidget {
  final DateTime date;
  final String autoSentence;
  final String note;
  final String dateKey;
  final bool isToday;
  final LedgrrPalette palette;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatShortDate;
  final Future<void> Function(String, String) onSaveNote;

  const _MemoryCard({
    required this.date,
    required this.autoSentence,
    required this.note,
    required this.dateKey,
    required this.isToday,
    required this.palette,
    required this.formatDate,
    required this.formatShortDate,
    required this.onSaveNote,
  });

  @override
  State<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<_MemoryCard> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isToday ? palette.accent : palette.border,
          width: widget.isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isToday
                          ? 'Today'
                          : widget.formatShortDate(widget.date),
                      style: GoogleFonts.syne(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.accent,
                          letterSpacing: 0.04),
                    ),
                    Text(
                      widget.formatDate(widget.date),
                      style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.ink),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: palette.border),
                  ),
                  child: Text('Auto-written',
                      style: GoogleFonts.syne(
                          fontSize: 10,
                          color: palette.inkMuted)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Auto sentence
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '"${widget.autoSentence}"',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: palette.ink,
                  height: 1.6),
            ),
          ),

          const SizedBox(height: 12),

          // Divider
          Divider(height: 1, color: palette.border),

          // Personal note section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note_rounded,
                        size: 14, color: palette.inkMuted),
                    const SizedBox(width: 6),
                    Text('Your note',
                        style: GoogleFonts.syne(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: palette.inkMuted)),
                    const Spacer(),
                    if (!_isEditing)
                      GestureDetector(
                        onTap: () => setState(() => _isEditing = true),
                        child: Text(
                          widget.note.isEmpty ? 'Add note' : 'Edit',
                          style: GoogleFonts.syne(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.accent),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (_isEditing) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 3,
                      style: GoogleFonts.syne(
                          fontSize: 13, color: palette.ink),
                      decoration: InputDecoration(
                        hintText:
                            'How did today feel financially? Any thoughts?',
                        hintStyle: GoogleFonts.syne(
                            fontSize: 12, color: palette.inkMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _controller.text = widget.note;
                          _isEditing = false;
                        }),
                        child: Text('Cancel',
                            style: GoogleFonts.syne(
                                fontSize: 13,
                                color: palette.inkMuted)),
                      ),
                      const Spacer(),
                      Material(
                        color: palette.accent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _isSaving
                              ? null
                              : () async {
                                  setState(() => _isSaving = true);
                                  await widget.onSaveNote(
                                      widget.dateKey, _controller.text);
                                  if (mounted) {
                                    setState(() {
                                      _isSaving = false;
                                      _isEditing = false;
                                    });
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: _isSaving
                                ? SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: palette.accentFg))
                                : Text('Save note',
                                    style: GoogleFonts.syne(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: palette.accentFg)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (widget.note.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      widget.note,
                      style: GoogleFonts.syne(
                          fontSize: 13,
                          color: palette.ink,
                          height: 1.5,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ] else ...[
                  Text(
                    'No note yet. Tap "Add note" to write something.',
                    style: GoogleFonts.syne(
                        fontSize: 12, color: palette.inkMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}