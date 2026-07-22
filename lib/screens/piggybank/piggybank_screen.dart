import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';

class PiggyBankScreen extends StatefulWidget {
  const PiggyBankScreen({super.key});

  @override
  State<PiggyBankScreen> createState() => _PiggyBankScreenState();
}

class _PiggyBankScreenState extends State<PiggyBankScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _transactionService = TransactionService();

  Stream<QuerySnapshot> get _jarsStream => _db
      .collection('users')
      .doc(_uid)
      .collection('piggybanks')
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
                      Text('Savings',
                          style: GoogleFonts.syne(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('Jars',
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
                      onTap: () => _showCreateJar(context, palette),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: palette.accentFg, size: 16),
                            const SizedBox(width: 6),
                            Text('New jar',
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
                'Money saved here is deducted from your True Balance.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _jarsStream,
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
                                painter: _JarPainter(
                                    color: palette.accent),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('No jars yet',
                                style: GoogleFonts.syne(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: palette.ink)),
                            const SizedBox(height: 8),
                            Text(
                              'Create a jar for your Emergency Fund, Goa Trip, New Phone — anything worth saving for.',
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
                                onTap: () => _showCreateJar(
                                    context, palette),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14),
                                  child: Text(
                                      'Create your first jar',
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

                  final jars = snapshot.data!.docs;
                  final totalSaved = jars.fold<double>(
                    0,
                    (sum, doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;
                      return sum +
                          ((data['currentAmount'] as num?)
                                  ?.toDouble() ??
                              0);
                    },
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        24, 0, 24, 24),
                    itemCount: jars.length + 1,
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total saved',
                                        style: GoogleFonts.syne(
                                            fontSize: 11,
                                            color: palette.isDark
                                                ? palette.inkMuted
                                                : Colors.white54),
                                      ),
                                      Text(
                                        _formatAmount(totalSaved),
                                        style: GoogleFonts.syne(
                                            fontSize: 28,
                                            fontWeight:
                                                FontWeight.w800,
                                            color: palette.accent,
                                            letterSpacing: -1),
                                      ),
                                      Text(
                                        'across ${jars.length} ${jars.length == 1 ? 'jar' : 'jars'}',
                                        style: GoogleFonts
                                            .dmSerifDisplay(
                                                fontSize: 13,
                                                fontStyle:
                                                    FontStyle.italic,
                                                color: palette.isDark
                                                    ? palette.inkMuted
                                                    : Colors
                                                        .white54),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 70, height: 70,
                                  decoration: BoxDecoration(
                                    color: palette.accent
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                  child: CustomPaint(
                                    painter: _JarPainter(
                                        color: palette.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final doc = jars[i - 1];
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final name =
                          data['name'] as String? ?? 'Jar';
                      final current =
                          (data['currentAmount'] as num?)
                                  ?.toDouble() ??
                              0;
                      final goal =
                          (data['goalAmount'] as num?)
                                  ?.toDouble() ??
                              0;
                      final hasGoal = goal > 0;
                      final progress = hasGoal
                          ? (current / goal).clamp(0.0, 1.0)
                          : 0.0;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _showJarDetail(
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
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48, height: 48,
                                      decoration: BoxDecoration(
                                        color: palette.accent
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                      child: CustomPaint(
                                        painter: _JarPainter(
                                            color: palette.accent),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(name,
                                              style:
                                                  GoogleFonts.syne(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight
                                                              .w700,
                                                      color: palette
                                                          .ink)),
                                          if (hasGoal)
                                            Text(
                                              '${_formatAmount(current)} of ${_formatAmount(goal)} goal',
                                              style:
                                                  GoogleFonts.syne(
                                                      fontSize: 11,
                                                      color: palette
                                                          .inkMuted),
                                            )
                                          else
                                            Text(
                                              _formatAmount(current),
                                              style:
                                                  GoogleFonts.syne(
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
                                          _formatAmount(current),
                                          style: GoogleFonts.syne(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.w800,
                                              color: palette.accent,
                                              letterSpacing: -0.5),
                                        ),
                                        Text('tap to manage',
                                            style: GoogleFonts.syne(
                                                fontSize: 9,
                                                color: palette
                                                    .inkMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                                if (hasGoal) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: palette.bg2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress >= 1.0
                                            ? const Color(
                                                0xFF2E7D32)
                                            : palette.accent,
                                      ),
                                      minHeight: 5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    progress >= 1.0
                                        ? 'Goal reached!'
                                        : '${(progress * 100).toStringAsFixed(0)}% of goal',
                                    style: GoogleFonts.syne(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: progress >= 1.0
                                            ? const Color(
                                                0xFF2E7D32)
                                            : palette.inkMuted),
                                  ),
                                ],
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

  void _showCreateJar(
      BuildContext context, LedgrrPalette palette) {
    final nameController = TextEditingController();
    final goalController = TextEditingController();
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
              Text('Create a jar',
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(
                'Give it a name. Set a goal if you want. Start saving.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
              const SizedBox(height: 20),
              _field(
                  controller: nameController,
                  label: 'Jar name',
                  hint:
                      'Emergency Fund, Goa Trip, New Phone...',
                  palette: palette),
              const SizedBox(height: 14),
              _field(
                  controller: goalController,
                  label: 'Goal amount (₹) — optional',
                  hint: '0',
                  palette: palette,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              Material(
                color: palette.accent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isSaving
                      ? null
                      : () async {
                          if (nameController.text
                              .trim()
                              .isEmpty) return;
                          setState(() => isSaving = true);
                          await _db
                              .collection('users')
                              .doc(_uid)
                              .collection('piggybanks')
                              .add({
                            'name':
                                nameController.text.trim(),
                            'goalAmount': double.tryParse(
                                    goalController.text
                                        .trim()) ??
                                0,
                            'currentAmount': 0.0,
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
                          ? SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.accentFg))
                          : Text('Create jar',
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
      ),
    );
  }

  void _showJarDetail(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Jar';
    final current =
        (data['currentAmount'] as num?)?.toDouble() ?? 0;
    final goal =
        (data['goalAmount'] as num?)?.toDouble() ?? 0;

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
                                goal > 0
                                    ? '${_formatAmount(current)} of ${_formatAmount(goal)}'
                                    : _formatAmount(current),
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
                              color: palette.accent,
                              letterSpacing: -1),
                        ),
                      ],
                    ),
                    if (goal > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (current / goal)
                              .clamp(0.0, 1.0),
                          backgroundColor: palette.bg2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  palette.accent),
                          minHeight: 6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: palette.accent,
                            borderRadius:
                                BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(14),
                              onTap: () {
                                Navigator.pop(context);
                                _showDepositSheet(
                                    context, palette, doc);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                child: Center(
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded,
                                          color:
                                              palette.accentFg,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text('Deposit',
                                          style:
                                              GoogleFonts.syne(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700,
                                                  color: palette
                                                      .accentFg)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Material(
                            color: palette.bg2,
                            borderRadius:
                                BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(14),
                              onTap: current <= 0
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _showWithdrawSheet(
                                          context, palette,
                                          doc);
                                    },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                      color: palette.border),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                          Icons.remove_rounded,
                                          color: current <= 0
                                              ? palette.border
                                              : palette.ink,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text('Withdraw',
                                          style:
                                              GoogleFonts.syne(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight
                                                          .w700,
                                                  color: current <=
                                                          0
                                                      ? palette
                                                          .border
                                                      : palette
                                                          .ink)),
                                    ],
                                  ),
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
                            onTap: () => _deleteJar(
                                context, palette, doc),
                            child: Text('Delete jar',
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
                      .collection('piggybanks')
                      .doc(doc.id)
                      .collection('entries')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No entries yet. Make your first deposit.',
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
                        final isDeposit =
                            entry['type'] == 'deposit';
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
                                    color: isDeposit
                                        ? palette.accent
                                            .withOpacity(0.12)
                                        : const Color(0xFFB5446E)
                                            .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(
                                            10),
                                  ),
                                  child: Icon(
                                    isDeposit
                                        ? Icons
                                            .arrow_downward_rounded
                                        : Icons
                                            .arrow_upward_rounded,
                                    color: isDeposit
                                        ? palette.accent
                                        : const Color(0xFFB5446E),
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
                                        isDeposit
                                            ? 'Deposited'
                                            : 'Withdrawn',
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
                                  '${isDeposit ? '+' : '-'}${_formatAmount(amount)}',
                                  style: GoogleFonts.syne(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDeposit
                                          ? palette.accent
                                          : const Color(
                                              0xFFB5446E)),
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

  void _showDepositSheet(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool isSaving = false;
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Jar';

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
              Text('Deposit to $name',
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(
                'This amount will be deducted from your True Balance.',
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
                  hint: 'Saved from this month allowance...',
                  palette: palette),
              const SizedBox(height: 24),
              Material(
                color: palette.accent,
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

                          final trueBalance =
                              await _transactionService
                                  .getTrueBalance();
                          if (amount > trueBalance) {
                            final proceed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: palette.card,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20)),
                                title: Text(
                                    'This exceeds your True Balance',
                                    style: GoogleFonts.syne(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: palette.ink)),
                                content: Text(
                                  'Your True Balance is ${_formatAmount(trueBalance)}. Saving ${_formatAmount(amount)} will put you ${_formatAmount(amount - trueBalance)} in the red. Continue anyway?',
                                  style: GoogleFonts.syne(
                                      fontSize: 13,
                                      color: palette.inkMuted,
                                      height: 1.5),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancel',
                                        style: GoogleFonts.syne(
                                            fontSize: 13,
                                            color: palette.inkMuted)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('Save anyway',
                                        style: GoogleFonts.syne(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: palette.accent)),
                                  ),
                                ],
                              ),
                            );
                            if (proceed != true) return;
                          }

                          setState(() => isSaving = true);

                          final batch = _db.batch();
                          final jarRef = _db
                              .collection('users')
                              .doc(_uid)
                              .collection('piggybanks')
                              .doc(doc.id);

                          batch.set(
                              jarRef
                                  .collection('entries')
                                  .doc(),
                              {
                                'type': 'deposit',
                                'amount': amount,
                                'note': noteController.text
                                    .trim(),
                                'date': Timestamp.now(),
                              });

                          final current =
                              (data['currentAmount'] as num?)
                                      ?.toDouble() ??
                                  0;
                          batch.update(jarRef, {
                            'currentAmount': current + amount,
                          });

                          await batch.commit();

                          await _transactionService
                              .addTransaction(
                            title: 'Saved to $name',
                            amount: amount,
                            category: 'savings',
                            type: 'expense',
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
                          ? SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.accentFg))
                          : Text('Save to jar',
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
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    bool isSaving = false;
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Jar';
    final current =
        (data['currentAmount'] as num?)?.toDouble() ?? 0;

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
              Text('Withdraw from $name',
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: palette.ink,
                      letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text(
                'Available: ${_formatAmount(current)}. This will be added back to your True Balance.',
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
                  controller: reasonController,
                  label: 'Reason (required)',
                  hint: 'Why are you withdrawing?',
                  palette: palette),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFB5446E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFB5446E)
                          .withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFFB5446E), size: 14),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Withdrawing reduces your savings. Only do this if you really need to.',
                        style: GoogleFonts.syne(
                            fontSize: 11,
                            color: const Color(0xFFB5446E),
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: const Color(0xFFB5446E),
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
                          if (reasonController.text
                              .trim()
                              .isEmpty) return;
                          if (amount > current) return;

                          final confirmed =
                              await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: palette.card,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20)),
                              title: Text('Are you sure?',
                                  style: GoogleFonts.syne(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: palette.ink)),
                              content: Text(
                                'You are withdrawing ${_formatAmount(amount)} from $name. This will be added back to your True Balance.',
                                style: GoogleFonts.syne(
                                    fontSize: 13,
                                    color: palette.inkMuted,
                                    height: 1.5),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                      context, false),
                                  child: Text('Cancel',
                                      style: GoogleFonts.syne(
                                          fontSize: 13,
                                          color:
                                              palette.inkMuted)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                      context, true),
                                  child: Text('Withdraw',
                                      style: GoogleFonts.syne(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: const Color(
                                              0xFFB5446E))),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;
                          setState(() => isSaving = true);

                          final batch = _db.batch();
                          final jarRef = _db
                              .collection('users')
                              .doc(_uid)
                              .collection('piggybanks')
                              .doc(doc.id);

                          batch.set(
                              jarRef
                                  .collection('entries')
                                  .doc(),
                              {
                                'type': 'withdrawal',
                                'amount': amount,
                                'note': reasonController.text
                                    .trim(),
                                'date': Timestamp.now(),
                              });

                          batch.update(jarRef, {
                            'currentAmount': current - amount,
                          });

                          await batch.commit();

                          await _transactionService
                              .addTransaction(
                            title: 'Withdrew from $name',
                            amount: amount,
                            category: 'savings',
                            type: 'income',
                            date: DateTime.now(),
                            note: reasonController.text.trim(),
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
                          : Text('Withdraw from jar',
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

  Future<void> _deleteJar(BuildContext context,
      LedgrrPalette palette, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Jar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete $name?',
            style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.ink)),
        content: Text(
          'This jar is empty. Deleting it cannot be undone.',
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
          .collection('piggybanks')
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

// ─── JAR PAINTER ───────────────────────────────────────────────────────────

class _JarPainter extends CustomPainter {
  final Color color;
  const _JarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 22;

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round;

    final pf = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy - 11 * s),
            width: 15 * s,
            height: 4 * s),
        Radius.circular(1.2 * s),
      ),
      pf,
    );

    final body = Path();
    body.moveTo(cx - 5 * s, cy - 9 * s);
    body.lineTo(cx - 5 * s, cy - 5 * s);
    body.quadraticBezierTo(
        cx - 11 * s, cy - 3 * s, cx - 11 * s, cy + 4 * s);
    body.lineTo(cx - 11 * s, cy + 8 * s);
    body.quadraticBezierTo(
        cx - 11 * s, cy + 12 * s, cx - 7 * s, cy + 12 * s);
    body.lineTo(cx + 7 * s, cy + 12 * s);
    body.quadraticBezierTo(
        cx + 11 * s, cy + 12 * s, cx + 11 * s, cy + 8 * s);
    body.lineTo(cx + 11 * s, cy + 4 * s);
    body.quadraticBezierTo(
        cx + 11 * s, cy - 3 * s, cx + 5 * s, cy - 5 * s);
    body.lineTo(cx + 5 * s, cy - 9 * s);
    body.close();
    canvas.drawPath(body, p);

    canvas.drawLine(
        Offset(cx - 8 * s, cy + 3 * s),
        Offset(cx + 8 * s, cy + 3 * s),
        fillLine);

    canvas.drawCircle(Offset(cx - 3 * s, cy - 1 * s), 1.4 * s, pf);
    canvas.drawCircle(
        Offset(cx + 4 * s, cy + 0.5 * s), 1.4 * s, pf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}