import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';

class DuesScreen extends StatefulWidget {
  const DuesScreen({super.key});

  @override
  State<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends State<DuesScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _transactionService = TransactionService();

  Stream<QuerySnapshot> get _duesStream => _db
      .collection('users')
      .doc(_uid)
      .collection('dues')
      .orderBy('createdAt', descending: false)
      .snapshots();

  String _formatAmount(double amount) {
    if (amount >= 100000)
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;

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
                  Material(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_rounded,
                            color: palette.ink, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dues',
                          style: GoogleFonts.syne(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('Tracker',
                          style: GoogleFonts.syne(
                              fontSize: 20,
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
                      onTap: () => _showCreateDue(context, palette),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: palette.accentFg, size: 16),
                            const SizedBox(width: 6),
                            Text('New due',
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
                'Track who owes you, and who you owe. Settling updates your True Balance.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _duesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: palette.accent, strokeWidth: 2),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: palette.bg2,
                                borderRadius:
                                    BorderRadius.circular(24),
                                border: Border.all(
                                    color: palette.border),
                              ),
                              child: CustomPaint(
                                painter: _DuesPainter(
                                    color: palette.accent),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('No dues yet',
                                style: GoogleFonts.syne(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: palette.ink)),
                            const SizedBox(height: 8),
                            Text(
                              'Add a due for money someone owes you, or money you owe someone else.',
                              style: GoogleFonts.syne(
                                  fontSize: 13,
                                  color: palette.inkMuted,
                                  height: 1.6),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Material(
                              color: palette.accent,
                              borderRadius:
                                  BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(14),
                                onTap: () => _showCreateDue(
                                    context, palette),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14),
                                  child: Text(
                                      'Add your first due',
                                      style:
                                          GoogleFonts.dmSerifDisplay(
                                              fontSize: 15,
                                              fontStyle:
                                                  FontStyle.italic,
                                              color:
                                                  palette.accentFg)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final dues = snapshot.data!.docs;

                  double owedToMe = 0;
                  double iOwe = 0;
                  for (final doc in dues) {
                    final data = doc.data() as Map<String, dynamic>;
                    final current =
                        (data['currentAmount'] as num?)?.toDouble() ??
                            0;
                    if (data['direction'] == 'owed_to_me') {
                      owedToMe += current;
                    } else {
                      iOwe += current;
                    }
                  }
                  final net = owedToMe - iOwe;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        24, 0, 24, 24),
                    itemCount: dues.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: palette.isDark
                                  ? palette.bg2
                                  : palette.ink,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: palette.isDark
                                  ? Border.all(
                                      color: palette.border)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            net >= 0
                                                ? 'Net — you are owed'
                                                : 'Net — you owe',
                                            style: GoogleFonts.syne(
                                                fontSize: 11,
                                                color: palette.isDark
                                                    ? palette.inkMuted
                                                    : Colors.white54),
                                          ),
                                          Text(
                                            _formatAmount(net.abs()),
                                            style: GoogleFonts.syne(
                                                fontSize: 28,
                                                fontWeight:
                                                    FontWeight.w800,
                                                color: net >= 0
                                                    ? palette.accent
                                                    : const Color(
                                                        0xFFB5446E),
                                                letterSpacing: -1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 60, height: 60,
                                      decoration: BoxDecoration(
                                        color: palette.accent
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(
                                                16),
                                      ),
                                      child: CustomPaint(
                                        painter: _DuesPainter(
                                            color: palette.accent),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DuesSummaryChip(
                                        label: 'Owed to you',
                                        value: _formatAmount(owedToMe),
                                        palette: palette,
                                        isDark: palette.isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _DuesSummaryChip(
                                        label: 'You owe',
                                        value: _formatAmount(iOwe),
                                        palette: palette,
                                        isDark: palette.isDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final doc = dues[i - 1];
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final name =
                          data['personName'] as String? ?? 'Someone';
                      final direction =
                          data['direction'] as String? ??
                              'owed_to_me';
                      final isOwedToMe = direction == 'owed_to_me';
                      final current =
                          (data['currentAmount'] as num?)
                                  ?.toDouble() ??
                              0;
                      final original =
                          (data['originalAmount'] as num?)
                                  ?.toDouble() ??
                              current;
                      final partiallySettled =
                          original > 0 && current < original;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _showDueDetail(
                              context, palette, doc),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius:
                                  BorderRadius.circular(18),
                              border: Border.all(
                                  color: palette.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: (isOwedToMe
                                            ? palette.accent
                                            : const Color(
                                                0xFFB5446E))
                                        .withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isOwedToMe
                                        ? Icons
                                            .arrow_downward_rounded
                                        : Icons
                                            .arrow_upward_rounded,
                                    color: isOwedToMe
                                        ? palette.accent
                                        : const Color(0xFFB5446E),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: GoogleFonts.syne(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: palette.ink)),
                                      Text(
                                        isOwedToMe
                                            ? 'owes you'
                                            : 'you owe',
                                        style: GoogleFonts.syne(
                                            fontSize: 11,
                                            color:
                                                palette.inkMuted),
                                      ),
                                      if (partiallySettled)
                                        Text(
                                          'of ${_formatAmount(original)} original',
                                          style: GoogleFonts.syne(
                                              fontSize: 10,
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
                                      _formatAmount(current),
                                      style: GoogleFonts.syne(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.w800,
                                          color: isOwedToMe
                                              ? palette.accent
                                              : const Color(
                                                  0xFFB5446E),
                                          letterSpacing: -0.5),
                                    ),
                                    Text('tap to manage',
                                        style: GoogleFonts.syne(
                                            fontSize: 9,
                                            color:
                                                palette.inkMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  void _showCreateDue(
      BuildContext context, LedgrrPalette palette) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String direction = 'owed_to_me';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: palette.bg,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add a due',
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(
                'Who owes who, and how much.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    ('owed_to_me', 'Owed to me'),
                    ('i_owe', 'I owe'),
                  ].map((entry) {
                    final value = entry.$1;
                    final label = entry.$2;
                    final isSelected = direction == value;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => direction = value),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (value == 'owed_to_me'
                                    ? palette.accent
                                    : const Color(0xFFB5446E))
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: GoogleFonts.syne(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
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
              _field(
                  controller: nameController,
                  label: 'Person\'s name',
                  hint: 'Priya, Hostel, Arjun...',
                  palette: palette),
              const SizedBox(height: 12),
              _field(
                  controller: amountController,
                  label: 'Amount (₹)',
                  hint: '0',
                  palette: palette,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _field(
                  controller: noteController,
                  label: 'Note (optional)',
                  hint: 'What was this for?',
                  palette: palette),
              const SizedBox(height: 24),
              Material(
                color: direction == 'owed_to_me'
                    ? palette.accent
                    : const Color(0xFFB5446E),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isSaving
                      ? null
                      : () async {
                          if (nameController.text
                              .trim()
                              .isEmpty) return;
                          final amount = double.tryParse(
                              amountController.text.trim());
                          if (amount == null || amount <= 0)
                            return;
                          setState(() => isSaving = true);
                          await _db
                              .collection('users')
                              .doc(_uid)
                              .collection('dues')
                              .add({
                            'personName':
                                nameController.text.trim(),
                            'direction': direction,
                            'originalAmount': amount,
                            'currentAmount': amount,
                            'note': noteController.text.trim(),
                            'createdAt':
                                FieldValue.serverTimestamp(),
                          });
                          if (context.mounted)
                            Navigator.pop(context);
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    child: Center(
                      child: isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : Text('Add due',
                              style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDueDetail(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['personName'] as String? ?? 'Someone';
    final direction =
        data['direction'] as String? ?? 'owed_to_me';
    final isOwedToMe = direction == 'owed_to_me';
    final current =
        (data['currentAmount'] as num?)?.toDouble() ?? 0;
    final original =
        (data['originalAmount'] as num?)?.toDouble() ?? current;
    final accentColor =
        isOwedToMe ? palette.accent : const Color(0xFFB5446E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: palette.bg,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                            color: palette.border,
                            borderRadius:
                                BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: GoogleFonts.syne(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w800,
                                      color: palette.ink,
                                      letterSpacing: -0.5)),
                              Text(
                                isOwedToMe
                                    ? 'owes you'
                                    : 'you owe',
                                style:
                                    GoogleFonts.dmSerifDisplay(
                                        fontSize: 14,
                                        fontStyle:
                                            FontStyle.italic,
                                        color:
                                            palette.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatAmount(current),
                          style: GoogleFonts.syne(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: -1),
                        ),
                      ],
                    ),
                    if (original > current) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 1 - (current / original),
                          backgroundColor: palette.bg2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  accentColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatAmount(original - current)} settled of ${_formatAmount(original)}',
                        style: GoogleFonts.syne(
                            fontSize: 11,
                            color: palette.inkMuted),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: accentColor,
                            borderRadius:
                                BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(14),
                              onTap: current <= 0
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _showSettleSheet(
                                          context,
                                          palette,
                                          doc);
                                    },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                child: Center(
                                  child: Text(
                                      isOwedToMe
                                          ? 'Mark as received'
                                          : 'Mark as paid',
                                      style: GoogleFonts.syne(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: palette.border),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('History',
                            style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: palette.ink)),
                        const Spacer(),
                        if (current <= 0)
                          GestureDetector(
                            onTap: () => _deleteDue(
                                context, palette, doc),
                            child: Text('Delete due',
                                style: GoogleFonts.syne(
                                    fontSize: 11,
                                    color: const Color(
                                        0xFFE53935))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db
                      .collection('users')
                      .doc(_uid)
                      .collection('dues')
                      .doc(doc.id)
                      .collection('entries')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No settlements yet.',
                          style: GoogleFonts.syne(
                              fontSize: 13,
                              color: palette.inkMuted),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                          24, 0, 24, 24),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, i) {
                        final entry = snapshot.data!.docs[i]
                            .data() as Map<String, dynamic>;
                        final amount =
                            (entry['amount'] as num).toDouble();
                        final date =
                            (entry['date'] as Timestamp)
                                .toDate();
                        final note =
                            entry['note'] as String? ?? '';

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                  color: palette.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: accentColor
                                        .withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: accentColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isOwedToMe
                                            ? 'Received'
                                            : 'Paid',
                                        style: GoogleFonts.syne(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: palette.ink),
                                      ),
                                      if (note.isNotEmpty)
                                        Text(note,
                                            style:
                                                GoogleFonts.syne(
                                                    fontSize: 11,
                                                    color: palette
                                                        .inkMuted)),
                                      Text(
                                        '${date.day}/${date.month}/${date.year}',
                                        style: GoogleFonts.syne(
                                            fontSize: 10,
                                            color:
                                                palette.inkMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatAmount(amount),
                                  style: GoogleFonts.syne(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  void _showSettleSheet(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool isSaving = false;
    final data = doc.data() as Map<String, dynamic>;
    final name = data['personName'] as String? ?? 'Someone';
    final direction =
        data['direction'] as String? ?? 'owed_to_me';
    final isOwedToMe = direction == 'owed_to_me';
    final current =
        (data['currentAmount'] as num?)?.toDouble() ?? 0;
    final accentColor =
        isOwedToMe ? palette.accent : const Color(0xFFB5446E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: palette.bg,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                  isOwedToMe
                      ? '$name paid you'
                      : 'You paid $name',
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(
                'Available to settle: ${_formatAmount(current)}. This updates your True Balance.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: GoogleFonts.syne(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: palette.ink),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.syne(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: palette.border),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.syne(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: palette.inkMuted),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _field(
                  controller: noteController,
                  label: 'Note (optional)',
                  hint: 'Add a note...',
                  palette: palette),
              const SizedBox(height: 24),
              Material(
                color: accentColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isSaving
                      ? null
                      : () async {
                          final amount = double.tryParse(
                              amountController.text.trim());
                          if (amount == null || amount <= 0)
                            return;
                          if (amount > current) return;
                          setState(() => isSaving = true);

                          final batch = _db.batch();
                          final dueRef = _db
                              .collection('users')
                              .doc(_uid)
                              .collection('dues')
                              .doc(doc.id);

                          batch.set(
                              dueRef.collection('entries').doc(),
                              {
                                'amount': amount,
                                'note':
                                    noteController.text.trim(),
                                'date': Timestamp.now(),
                              });

                          batch.update(dueRef, {
                            'currentAmount': current - amount,
                          });

                          await batch.commit();

                          await _transactionService
                              .addTransaction(
                            title: isOwedToMe
                                ? 'Received from $name'
                                : 'Paid $name',
                            amount: amount,
                            category: 'dues',
                            type: isOwedToMe
                                ? 'income'
                                : 'expense',
                            date: DateTime.now(),
                            note: noteController.text.trim(),
                          );

                          if (context.mounted)
                            Navigator.pop(context);
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    child: Center(
                      child: isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : Text(
                              isOwedToMe
                                  ? 'Confirm received'
                                  : 'Confirm paid',
                              style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDue(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['personName'] as String? ?? 'Someone';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete due with $name?',
            style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.ink)),
        content: Text(
          'This due is fully settled. Deleting it cannot be undone.',
          style: GoogleFonts.syne(
              fontSize: 13,
              color: palette.inkMuted,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.syne(
                    fontSize: 13, color: palette.inkMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53935))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('dues')
          .doc(doc.id)
          .delete();
      if (context.mounted) Navigator.pop(context);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
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

// ─── SUMMARY CHIP ──────────────────────────────────────────────────────────

class _DuesSummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final LedgrrPalette palette;
  final bool isDark;

  const _DuesSummaryChip({
    required this.label,
    required this.value,
    required this.palette,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
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
                  color:
                      isDark ? palette.inkMuted : Colors.white54)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.accent)),
        ],
      ),
    );
  }
}

// ─── DUES ICON PAINTER ─────────────────────────────────────────────────────
// Two opposite-facing arrows in a loop, representing money flowing both
// ways between the user and other people.

class _DuesPainter extends CustomPainter {
  final Color color;
  const _DuesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 22;

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Top arrow curving left-to-right
    final top = Path();
    top.moveTo(cx - 8 * s, cy - 3 * s);
    top.quadraticBezierTo(
        cx, cy - 10 * s, cx + 8 * s, cy - 3 * s);
    canvas.drawPath(top, p);
    // Arrowhead
    final topHead = Path();
    topHead.moveTo(cx + 8 * s, cy - 3 * s);
    topHead.lineTo(cx + 4 * s, cy - 5 * s);
    topHead.moveTo(cx + 8 * s, cy - 3 * s);
    topHead.lineTo(cx + 5 * s, cy + 0.5 * s);
    canvas.drawPath(topHead, p);

    // Bottom arrow curving right-to-left
    final bottom = Path();
    bottom.moveTo(cx + 8 * s, cy + 3 * s);
    bottom.quadraticBezierTo(
        cx, cy + 10 * s, cx - 8 * s, cy + 3 * s);
    canvas.drawPath(bottom, p);
    // Arrowhead
    final bottomHead = Path();
    bottomHead.moveTo(cx - 8 * s, cy + 3 * s);
    bottomHead.lineTo(cx - 4 * s, cy + 5 * s);
    bottomHead.moveTo(cx - 8 * s, cy + 3 * s);
    bottomHead.lineTo(cx - 5 * s, cy - 0.5 * s);
    canvas.drawPath(bottomHead, p);

    // Small dot markers at each end (like two people)
    canvas.drawCircle(Offset(cx - 8 * s, cy - 3 * s), 1.6 * s, pf);
    canvas.drawCircle(Offset(cx + 8 * s, cy + 3 * s), 1.6 * s, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}