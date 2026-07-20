import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class SpendListScreen extends StatefulWidget {
  const SpendListScreen({super.key});

  @override
  State<SpendListScreen> createState() => _SpendListScreenState();
}

class _SpendListScreenState extends State<SpendListScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> get _listsStream => _db
      .collection('users')
      .doc(_uid)
      .collection('spendlists')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> _createList(String name, double budget) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('spendlists')
        .add({
      'name': name,
      'budget': budget,
      'createdAt': FieldValue.serverTimestamp(),
      'completed': false,
    });
  }

  Future<void> _addItem(String listId, String name, double amount) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('spendlists')
        .doc(listId)
        .collection('items')
        .add({
      'name': name,
      'amount': amount,
      'checked': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _toggleItem(String listId, String itemId, bool current) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('spendlists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update({'checked': !current});
  }

  Future<void> _deleteList(String listId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('spendlists')
        .doc(listId)
        .delete();
  }

  void _showCreateList(BuildContext context, LedgrrPalette palette) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
            Text('New Spend List',
                style: GoogleFonts.syne(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: palette.ink, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('Give it a name and set a budget cap.',
                style: GoogleFonts.syne(fontSize: 13, color: palette.inkMuted)),
            const SizedBox(height: 20),
            _field(controller: nameController,
                hint: 'e.g. Shopping with Dad\'s 10K',
                label: 'List name', palette: palette),
            const SizedBox(height: 12),
            _field(controller: budgetController,
                hint: '0.00', label: 'Budget cap (₹)',
                palette: palette, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            Material(
              color: palette.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final budget = double.tryParse(budgetController.text) ?? 0;
                  await _createList(nameController.text.trim(), budget);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Create list',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 17, fontStyle: FontStyle.italic,
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

  void _showAddItem(BuildContext context, String listId, LedgrrPalette palette) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
            Text('Add item',
                style: GoogleFonts.syne(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: palette.ink, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            _field(controller: nameController,
                hint: 'What are you buying?',
                label: 'Item name', palette: palette),
            const SizedBox(height: 12),
            _field(controller: amountController,
                hint: '0.00', label: 'Estimated amount (₹)',
                palette: palette, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            Material(
              color: palette.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final amount = double.tryParse(amountController.text) ?? 0;
                  await _addItem(listId, nameController.text.trim(), amount);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Add item',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 17, fontStyle: FontStyle.italic,
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

  Widget _field({
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
                fontSize: 12, fontWeight: FontWeight.w600,
                color: palette.inkMuted, letterSpacing: 0.05)),
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
            style: GoogleFonts.syne(fontSize: 15, color: palette.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.syne(fontSize: 14, color: palette.inkMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(double amount) {
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Text('Spend List',
                      style: GoogleFonts.syne(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: palette.ink, letterSpacing: -0.5)),
                  const Spacer(),
                  Material(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showCreateList(context, palette),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: palette.accentFg, size: 16),
                            const SizedBox(width: 6),
                            Text('New list',
                                style: GoogleFonts.syne(
                                    fontSize: 13, fontWeight: FontWeight.w600,
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
                'Plan before you spend. Check off as you go.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 14, fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _listsStream,
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
                          Icon(Icons.checklist_rounded,
                              color: palette.inkMuted, size: 48),
                          const SizedBox(height: 12),
                          Text('No lists yet',
                              style: GoogleFonts.syne(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          const SizedBox(height: 6),
                          Text(
                            'Create a list before your next\nshopping trip or errand.',
                            style: GoogleFonts.syne(
                                fontSize: 13, color: palette.inkMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, i) {
                      final doc = snapshot.data!.docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final budget =
                          (data['budget'] as num?)?.toDouble() ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SpendListCard(
                          listId: doc.id,
                          name: data['name'] ?? 'Untitled',
                          budget: budget,
                          palette: palette,
                          uid: _uid,
                          onAddItem: () =>
                              _showAddItem(context, doc.id, palette),
                          onDelete: () => _deleteList(doc.id),
                          onToggleItem: _toggleItem,
                          formatAmount: _fmt,
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

class _SpendListCard extends StatelessWidget {
  final String listId;
  final String name;
  final double budget;
  final LedgrrPalette palette;
  final String uid;
  final VoidCallback onAddItem;
  final VoidCallback onDelete;
  final Future<void> Function(String, String, bool) onToggleItem;
  final String Function(double) formatAmount;

  const _SpendListCard({
    required this.listId,
    required this.name,
    required this.budget,
    required this.palette,
    required this.uid,
    required this.onAddItem,
    required this.onDelete,
    required this.onToggleItem,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('spendlists')
          .doc(listId)
          .collection('items')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        final items = snapshot.data?.docs ?? [];
        double totalSpent = 0;
        int checkedCount = 0;

        for (final item in items) {
          final data = item.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0;
          final checked = data['checked'] == true;
          if (checked) {
            totalSpent += amount;
            checkedCount++;
          }
        }

        final remaining = budget - totalSpent;
        final progress =
            budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
        final isOverBudget = remaining < 0;

        return Container(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverBudget
                  ? const Color(0xFFE53935).withOpacity(0.4)
                  : palette.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: GoogleFonts.syne(
                                  fontSize: 15, fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          if (budget > 0)
                            Text('Budget cap — ${formatAmount(budget)}',
                                style: GoogleFonts.syne(
                                    fontSize: 11, color: palette.inkMuted)),
                        ],
                      ),
                    ),
                    if (budget > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isOverBudget ? 'OVER BUDGET' : 'REMAINING',
                            style: GoogleFonts.syne(
                                fontSize: 9,
                                color: isOverBudget
                                    ? const Color(0xFFE53935)
                                    : palette.inkMuted,
                                letterSpacing: 0.05),
                          ),
                          Text(
                            formatAmount(remaining.abs()),
                            style: GoogleFonts.syne(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: isOverBudget
                                    ? const Color(0xFFE53935)
                                    : palette.accent),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (budget > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: palette.bg2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget
                            ? const Color(0xFFE53935)
                            : palette.accent,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text('No items yet. Add what you need to buy.',
                      style: GoogleFonts.syne(
                          fontSize: 12, color: palette.inkMuted)),
                )
              else
                ...items.map((item) {
                  final data = item.data() as Map<String, dynamic>;
                  final checked = data['checked'] == true;
                  final amount = (data['amount'] as num?)?.toDouble() ?? 0;

                  return InkWell(
                    onTap: () => onToggleItem(listId, item.id, checked),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: checked
                                        ? palette.accent
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: checked
                                          ? palette.accent
                                          : palette.border,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: checked
                                      ? Icon(Icons.check_rounded,
                                          color: palette.accentFg, size: 13)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    data['name'] ?? '',
                                    style: GoogleFonts.syne(
                                      fontSize: 13,
                                      color: checked
                                          ? palette.inkMuted
                                          : palette.ink,
                                      decoration: checked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                Text(
                                  amount > 0 ? formatAmount(amount) : '',
                                  style: GoogleFonts.syne(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: checked
                                        ? palette.inkMuted
                                        : palette.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                              height: 1,
                              color: palette.border,
                              thickness: 0.5),
                        ],
                      ),
                    ),
                  );
                }),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text('$checkedCount/${items.length} done',
                        style: GoogleFonts.syne(
                            fontSize: 11, color: palette.inkMuted)),
                    const Spacer(),
                    Material(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onAddItem,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded,
                                  color: palette.accent, size: 14),
                              const SizedBox(width: 4),
                              Text('Add item',
                                  style: GoogleFonts.syne(
                                      fontSize: 12, fontWeight: FontWeight.w500,
                                      color: palette.accent)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: palette.bg2,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.delete_outline_rounded,
                              color: const Color(0xFFE53935), size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}