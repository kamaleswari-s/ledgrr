import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _transactionService = TransactionService();
  final _searchController = TextEditingController();
  String _filterType = 'All';
  int _filterMonth = 0;
  String _searchQuery = '';

  final List<String> _typeFilters = ['All', 'Income', 'Expense'];

  final List<String> _monthNames = [
    'All months', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount >= 100000)
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  List<QueryDocumentSnapshot> _filterDocs(
      List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title =
          (data['title'] as String? ?? '').toLowerCase();
      final type = data['type'] as String? ?? '';
      final date = (data['date'] as Timestamp).toDate();

      // Search filter
      if (_searchQuery.isNotEmpty &&
          !title.contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Type filter
      if (_filterType == 'Income' && type != 'income')
        return false;
      if (_filterType == 'Expense' && type != 'expense')
        return false;

      // Month filter
      if (_filterMonth > 0 && date.month != _filterMonth)
        return false;

      return true;
    }).toList();
  }

  double _calculateRunningBalance(
      List<QueryDocumentSnapshot> docs) {
    double balance = 0;
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num).toDouble();
      if (data['type'] == 'income') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }
    return balance;
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
                      Text('Transaction',
                          style: GoogleFonts.syne(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('History',
                          style: GoogleFonts.syne(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: palette.accent,
                              letterSpacing: -0.5)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.border),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.syne(
                      fontSize: 14, color: palette.ink),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: GoogleFonts.syne(
                        fontSize: 13, color: palette.inkMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: palette.inkMuted, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.clear_rounded,
                                color: palette.inkMuted, size: 16),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Type filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  ..._typeFilters.map((f) {
                    final isSelected = _filterType == f;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _filterType = f),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                        child: Text(f,
                            style: GoogleFonts.syne(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? palette.accentFg
                                    : palette.inkMuted)),
                      ),
                    );
                  }),
                  // Month filter
                  ...List.generate(13, (i) {
                    final isSelected = _filterMonth == i;
                    if (i == 0) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => setState(
                          () => _filterMonth =
                              _filterMonth == i ? 0 : i),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? palette.accent.withOpacity(0.15)
                              : palette.bg2,
                          borderRadius:
                              BorderRadius.circular(100),
                          border: Border.all(
                              color: isSelected
                                  ? palette.accent
                                  : palette.border),
                        ),
                        child: Text(_monthNames[i],
                            style: GoogleFonts.syne(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? palette.accent
                                    : palette.inkMuted)),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Transaction list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _transactionService.getTransactionsStream(),
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
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              color: palette.inkMuted, size: 48),
                          const SizedBox(height: 12),
                          Text('No transactions yet',
                              style: GoogleFonts.syne(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          const SizedBox(height: 6),
                          Text('Add your first transaction\nto get started.',
                              style: GoogleFonts.syne(
                                  fontSize: 13,
                                  color: palette.inkMuted),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  final allDocs = snapshot.data!.docs;
                  final filtered = _filterDocs(allDocs);
                  final balance =
                      _calculateRunningBalance(allDocs);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              color: palette.inkMuted, size: 48),
                          const SizedBox(height: 12),
                          Text('No results found',
                              style: GoogleFonts.syne(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          const SizedBox(height: 6),
                          Text('Try a different search or filter.',
                              style: GoogleFonts.syne(
                                  fontSize: 13,
                                  color: palette.inkMuted)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        24, 0, 24, 24),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, i) {
                      // Balance summary card
                      if (i == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: palette.isDark
                                  ? palette.bg2
                                  : palette.ink,
                              borderRadius:
                                  BorderRadius.circular(16),
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
                                        'True Balance',
                                        style: GoogleFonts.syne(
                                            fontSize: 11,
                                            color: palette.isDark
                                                ? palette.inkMuted
                                                : Colors.white54),
                                      ),
                                      Text(
                                        _formatAmount(
                                            balance.abs()),
                                        style: GoogleFonts.syne(
                                            fontSize: 24,
                                            fontWeight:
                                                FontWeight.w800,
                                            color: balance >= 0
                                                ? palette.accent
                                                : const Color(
                                                    0xFFE53935),
                                            letterSpacing: -0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${filtered.length} transactions',
                                      style: GoogleFonts.syne(
                                          fontSize: 11,
                                          color: palette.isDark
                                              ? palette.inkMuted
                                              : Colors.white54),
                                    ),
                                    Text(
                                      balance >= 0
                                          ? 'In the clear'
                                          : 'In the red',
                                      style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 14,
                                          fontStyle:
                                              FontStyle.italic,
                                          color: balance >= 0
                                              ? palette.accent
                                              : const Color(
                                                  0xFFE53935)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final doc = filtered[i - 1];
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final isIncome = data['type'] == 'income';
                      final amount =
                          (data['amount'] as num).toDouble();
                      final date =
                          (data['date'] as Timestamp).toDate();

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key(doc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin:
                                const EdgeInsets.only(left: 60),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                                right: 20),
                            child: const Icon(
                                Icons.delete_outline_rounded,
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
                            }
                            return confirmed;
                          },
                          child: GestureDetector(
                            onTap: () => _showEditSheet(
                                context, palette, doc),
                            child: Container(
                              padding: const EdgeInsets.all(14),
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
                                              .withOpacity(0.12)
                                          : const Color(
                                                  0xFFB5446E)
                                              .withOpacity(0.1),
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
                                            data['title'] ?? '',
                                            style: GoogleFonts
                                                .syne(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                    color: palette
                                                        .ink)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_capitalize(data['category'] ?? '')} · ${date.day}/${date.month}/${date.year}',
                                          style: GoogleFonts.syne(
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
                                        style: GoogleFonts.syne(
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
                                          style: GoogleFonts.syne(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, LedgrrPalette palette,
      DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final titleController =
        TextEditingController(text: data['title'] ?? '');
    final amountController = TextEditingController(
        text: (data['amount'] as num?)?.toString() ?? '');
    final noteController =
        TextEditingController(text: data['note'] ?? '');
    String type = data['type'] ?? 'expense';
    String selectedCategory = data['category'] ?? 'food';
    DateTime selectedDate =
        (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    bool isSaving = false;

    final expenseCategories = [
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

    final incomeCategories = [
      {'id': 'salary', 'name': 'Salary'},
      {'id': 'freelance', 'name': 'Freelance'},
      {'id': 'allowance', 'name': 'Allowance'},
      {'id': 'gift', 'name': 'Gift'},
      {'id': 'investment', 'name': 'Investment'},
      {'id': 'refund', 'name': 'Refund'},
      {'id': 'business', 'name': 'Business'},
      {'id': 'other_income', 'name': 'Other'},
    ];

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
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Edit transaction',
                    style: GoogleFonts.syne(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: palette.ink,
                        letterSpacing: -0.5)),
                const SizedBox(height: 20),

                // Type toggle
                Container(
                  decoration: BoxDecoration(
                    color: palette.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: ['expense', 'income'].map((t) {
                      final isSelected = type == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => type = t),
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

                // Title
                _editField(
                    controller: titleController,
                    label: 'Title',
                    hint: 'What was this for?',
                    palette: palette),
                const SizedBox(height: 12),

                // Amount
                _editField(
                    controller: amountController,
                    label: 'Amount (₹)',
                    hint: '0.00',
                    palette: palette,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),

                // Categories
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
                    itemCount: type == 'expense'
                        ? expenseCategories.length
                        : incomeCategories.length,
                    itemBuilder: (context, i) {
                      final cats = type == 'expense'
                          ? expenseCategories
                          : incomeCategories;
                      final cat = cats[i];
                      final isSelected =
                          selectedCategory == cat['id'];
                      return GestureDetector(
                        onTap: () => setState(
                            () => selectedCategory = cat['id']!),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          margin:
                              const EdgeInsets.only(right: 8),
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
                          child: Text(cat['name']!,
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

                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
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
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: GoogleFonts.syne(
                              fontSize: 14, color: palette.ink),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Note
                _editField(
                    controller: noteController,
                    label: 'Note (optional)',
                    hint: 'Add a note...',
                    palette: palette),
                const SizedBox(height: 24),

                // Save button
                Material(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isSaving
                        ? null
                        : () async {
                            if (titleController.text
                                .trim()
                                .isEmpty) return;
                            final amount = double.tryParse(
                                amountController.text.trim());
                            if (amount == null || amount <= 0)
                              return;
                            setState(() => isSaving = true);
                            await _transactionService
                                .updateTransaction(
                              transactionId: doc.id,
                              title:
                                  titleController.text.trim(),
                              amount: amount,
                              category: selectedCategory,
                              type: type,
                              date: selectedDate,
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
                            : Text('Save changes',
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
      ),
    );
  }

  Widget _editField({
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
            style:
                GoogleFonts.syne(fontSize: 15, color: palette.ink),
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

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}