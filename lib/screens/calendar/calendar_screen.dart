import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> get _eventsStream => _db
      .collection('users')
      .doc(_uid)
      .collection('events')
      .orderBy('date')
      .snapshots();

  void _showAddEvent(BuildContext context, LedgrrPalette palette) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventSheet(
        palette: palette,
        uid: _uid,
        db: _db,
      ),
    );
  }

  void _showEditEvent(
      BuildContext context, LedgrrPalette palette, DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventSheet(
        palette: palette,
        uid: _uid,
        db: _db,
        existingDoc: doc,
      ),
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  Future<void> _addSavings(
      String eventId, double amount, double current) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('events')
        .doc(eventId)
        .update({'savedAmount': current + amount});
  }

  String _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final diff = eventDay.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return '${diff.abs()} days ago';
    return 'In $diff days';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  Color _priorityColor(String priority, LedgrrPalette palette) {
    switch (priority) {
      case 'Must happen':
        return const Color(0xFFE53935);
      case 'Want to happen':
        return palette.accent;
      case 'Maybe':
        return palette.inkMuted;
      default:
        return palette.accent;
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Event',
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                              letterSpacing: -0.5)),
                      Text('Wallet',
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
                      onTap: () => _showAddEvent(context, palette),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded,
                                color: palette.accentFg, size: 16),
                            const SizedBox(width: 6),
                            Text('Add event',
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
                'Plan for what matters. Save before you spend.',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: palette.inkMuted),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _eventsStream,
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
                          SizedBox(
                            width: 56, height: 56,
                            child: CustomPaint(
                              painter: _EventIconPainter(
                                  type: 'general',
                                  color: palette.inkMuted.withOpacity(0.3)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('No events yet',
                              style: GoogleFonts.syne(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: palette.ink)),
                          const SizedBox(height: 8),
                          Text(
                            'Add an upcoming birthday, trip,\nor anything that needs saving for.',
                            style: GoogleFonts.syne(
                                fontSize: 13, color: palette.inkMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Material(
                            color: palette.accent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _showAddEvent(context, palette),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                child: Text('Add your first event',
                                    style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: palette.accentFg)),
                              ),
                            ),
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
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final date = (data['date'] as Timestamp).toDate();
                      final budget = (data['budget'] as num?)?.toDouble() ?? 0;
                      final saved =
                          (data['savedAmount'] as num?)?.toDouble() ?? 0;
                      final progress =
                          budget > 0 ? (saved / budget).clamp(0.0, 1.0) : 0.0;
                      final priority =
                          data['priority'] as String? ?? 'Want to happen';
                      final iconType = data['iconType'] as String? ?? 'general';
                      final daysUntil = _daysUntil(date);
                      final isUrgent = date
                              .difference(DateTime.now())
                              .inDays
                              .abs() <= 7 &&
                          date.isAfter(DateTime.now());
                      final dailySaving = budget > 0 && saved < budget
                          ? () {
                              final daysLeft = date
                                  .difference(DateTime.now())
                                  .inDays;
                              if (daysLeft <= 0) return 0.0;
                              return (budget - saved) / daysLeft;
                            }()
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isUrgent
                                  ? palette.accent
                                  : palette.border,
                              width: isUrgent ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event header
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        color:
                                            palette.accent.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: CustomPaint(
                                        painter: _EventIconPainter(
                                          type: iconType,
                                          color: palette.accent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? 'Untitled',
                                            style: GoogleFonts.syne(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: palette.ink),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 6, height: 6,
                                                decoration: BoxDecoration(
                                                  color: _priorityColor(
                                                      priority, palette),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(priority,
                                                  style: GoogleFonts.syne(
                                                      fontSize: 11,
                                                      color: _priorityColor(
                                                          priority, palette))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isUrgent
                                                ? palette.accent
                                                    .withOpacity(0.12)
                                                : palette.bg2,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Text(daysUntil,
                                              style: GoogleFonts.syne(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isUrgent
                                                      ? palette.accent
                                                      : palette.inkMuted)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${date.day}/${date.month}/${date.year}',
                                          style: GoogleFonts.syne(
                                              fontSize: 10,
                                              color: palette.inkMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Budget and savings
                              if (budget > 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Saved so far',
                                                style: GoogleFonts.syne(
                                                    fontSize: 10,
                                                    color: palette.inkMuted)),
                                            Text(
                                              _formatAmount(saved),
                                              style: GoogleFonts.syne(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color: palette.accent,
                                                  letterSpacing: -0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text('Goal',
                                              style: GoogleFonts.syne(
                                                  fontSize: 10,
                                                  color: palette.inkMuted)),
                                          Text(
                                            _formatAmount(budget),
                                            style: GoogleFonts.syne(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: palette.ink,
                                                letterSpacing: -0.5),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: palette.bg2,
                                      valueColor: AlwaysStoppedAnimation(
                                          progress >= 1.0
                                              ? const Color(0xFF2E7D32)
                                              : palette.accent),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),

                                if (dailySaving > 0) ...[
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'Save ${_formatAmount(dailySaving)}/day to hit your goal',
                                      style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: palette.inkMuted),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 12),
                              ],

                              if (data['notes'] != null &&
                                  (data['notes'] as String).isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 0),
                                  child: Text(
                                    data['notes'],
                                    style: GoogleFonts.syne(
                                        fontSize: 12,
                                        color: palette.inkMuted,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              Divider(height: 1, color: palette.border),

                              // Actions
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    if (budget > 0 && saved < budget)
                                      Material(
                                        color: palette.accent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          onTap: () => _showAddSavings(
                                              context, doc.id, saved, palette),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.savings_rounded,
                                                    color: palette.accentFg,
                                                    size: 14),
                                                const SizedBox(width: 5),
                                                Text('Add savings',
                                                    style: GoogleFonts.syne(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            palette.accentFg)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Material(
                                      color: palette.bg2,
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        onTap: () => _showEditEvent(
                                            context, palette, doc),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(Icons.edit_rounded,
                                              color: palette.accent, size: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Material(
                                      color: palette.bg2,
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        onTap: () => _deleteEvent(doc.id),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                              Icons.delete_outline_rounded,
                                              color: const Color(0xFFE53935),
                                              size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }

  void _showAddSavings(BuildContext context, String eventId, double current,
      LedgrrPalette palette) {
    final controller = TextEditingController();
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
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
            Text('Add savings',
                style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: palette.ink,
                    letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('How much are you setting aside for this event?',
                style:
                    GoogleFonts.syne(fontSize: 13, color: palette.inkMuted)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: palette.bg2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.syne(fontSize: 15, color: palette.ink),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle:
                      GoogleFonts.syne(fontSize: 14, color: palette.inkMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  prefixText: '₹ ',
                  prefixStyle:
                      GoogleFonts.syne(fontSize: 15, color: palette.inkMuted),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: palette.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final amount = double.tryParse(controller.text.trim());
                  if (amount == null || amount <= 0) return;
                  await _addSavings(eventId, amount, current);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Save toward this event',
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
}

// ─── EVENT SHEET ───────────────────────────────────────────────────────────

class _EventSheet extends StatefulWidget {
  final LedgrrPalette palette;
  final String uid;
  final FirebaseFirestore db;
  final DocumentSnapshot? existingDoc;

  const _EventSheet({
    required this.palette,
    required this.uid,
    required this.db,
    this.existingDoc,
  });

  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedPriority = 'Want to happen';
  String _selectedIcon = 'general';
  bool _isSaving = false;

  final List<String> _priorities = [
    'Must happen',
    'Want to happen',
    'Maybe',
  ];

  final List<Map<String, String>> _iconOptions = [
    {'type': 'birthday', 'label': 'Birthday'},
    {'type': 'travel_plane', 'label': 'Flight'},
    {'type': 'travel_train', 'label': 'Train'},
    {'type': 'travel_bus', 'label': 'Bus'},
    {'type': 'travel_bike', 'label': 'Road trip'},
    {'type': 'shopping', 'label': 'Shopping'},
    {'type': 'festival', 'label': 'Festival'},
    {'type': 'food', 'label': 'Food'},
    {'type': 'education', 'label': 'Education'},
    {'type': 'health', 'label': 'Health'},
    {'type': 'music', 'label': 'Concert'},
    {'type': 'gift', 'label': 'Gift'},
    {'type': 'general', 'label': 'General'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingDoc != null) {
      final data = widget.existingDoc!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _budgetController.text =
          (data['budget'] as num?)?.toStringAsFixed(0) ?? '';
      _notesController.text = data['notes'] ?? '';
      _selectedDate = (data['date'] as Timestamp).toDate();
      _selectedPriority = data['priority'] ?? 'Want to happen';
      _selectedIcon = data['iconType'] ?? 'general';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
        'budget': double.tryParse(_budgetController.text.trim()) ?? 0,
        'notes': _notesController.text.trim(),
        'priority': _selectedPriority,
        'iconType': _selectedIcon,
        'savedAmount': widget.existingDoc != null
            ? (widget.existingDoc!.data()
                    as Map<String, dynamic>)['savedAmount'] ??
                0
            : 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.existingDoc != null) {
        await widget.db
            .collection('users')
            .doc(widget.uid)
            .collection('events')
            .doc(widget.existingDoc!.id)
            .update(data);
      } else {
        await widget.db
            .collection('users')
            .doc(widget.uid)
            .collection('events')
            .add(data);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
            Text(
              widget.existingDoc != null ? 'Edit event' : 'New event',
              style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: palette.ink,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 20),

            // Icon picker
            Text('Choose an icon',
                style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.inkMuted,
                    letterSpacing: 0.04)),
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _iconOptions.length,
                itemBuilder: (context, i) {
                  final opt = _iconOptions[i];
                  final isSelected = _selectedIcon == opt['type'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIcon = opt['type']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      width: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.accent.withOpacity(0.12)
                            : palette.bg2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? palette.accent
                                : palette.border,
                            width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28, height: 28,
                            child: CustomPaint(
                              painter: _EventIconPainter(
                                type: opt['type']!,
                                color: isSelected
                                    ? palette.accent
                                    : palette.inkMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(opt['label']!,
                              style: GoogleFonts.syne(
                                  fontSize: 8,
                                  color: isSelected
                                      ? palette.accent
                                      : palette.inkMuted)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Name
            _field(
                controller: _nameController,
                label: 'Event name',
                hint: 'e.g. Appa\'s birthday',
                palette: palette),

            const SizedBox(height: 12),

            // Date
            Text('Date',
                style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.inkMuted,
                    letterSpacing: 0.04)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
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

            // Budget
            _field(
                controller: _budgetController,
                label: 'Budget goal (₹)',
                hint: '0',
                palette: palette,
                keyboardType: TextInputType.number),

            const SizedBox(height: 12),

            // Priority
            Text('Priority',
                style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.inkMuted,
                    letterSpacing: 0.04)),
            const SizedBox(height: 8),
            Row(
              children: _priorities.map((p) {
                final isSelected = _selectedPriority == p;
                Color pColor;
                switch (p) {
                  case 'Must happen':
                    pColor = const Color(0xFFE53935);
                    break;
                  case 'Want to happen':
                    pColor = palette.accent;
                    break;
                  default:
                    pColor = palette.inkMuted;
                }
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: p != _priorities.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? pColor.withOpacity(0.12)
                            : palette.bg2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected ? pColor : palette.border),
                      ),
                      child: Center(
                        child: Text(
                          p == 'Want to happen' ? 'Want it' : p,
                          style: GoogleFonts.syne(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? pColor : palette.inkMuted),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Notes
            _field(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Anything to keep in mind?',
                palette: palette),

            const SizedBox(height: 24),

            Material(
              color: palette.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isSaving ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: palette.accentFg))
                        : Text(
                            widget.existingDoc != null
                                ? 'Save changes'
                                : 'Create event',
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
                letterSpacing: 0.04)),
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
              hintStyle:
                  GoogleFonts.syne(fontSize: 14, color: palette.inkMuted),
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

// ─── EVENT ICON PAINTER ────────────────────────────────────────────────────

class _EventIconPainter extends CustomPainter {
  final String type;
  final Color color;

  const _EventIconPainter({required this.type, required this.color});

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
      case 'birthday':
        // Cake with candle
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 12, cy, cx + 12, cy + 12),
                const Radius.circular(3)),
            p);
        canvas.drawLine(Offset(cx - 12, cy + 6), Offset(cx + 12, cy + 6), p);
        canvas.drawLine(Offset(cx, cy - 6), Offset(cx, cy), p);
        canvas.drawCircle(Offset(cx, cy - 8), 3, pf);
        break;

      case 'travel_plane':
        final path = Path();
        path.moveTo(cx - 12, cy + 4);
        path.lineTo(cx + 10, cy - 2);
        path.lineTo(cx + 12, cy);
        path.lineTo(cx - 2, cy + 6);
        canvas.drawPath(path, p);
        canvas.drawLine(Offset(cx - 4, cy + 6), Offset(cx + 4, cy + 8), p);
        canvas.drawLine(Offset(cx - 10, cy + 2), Offset(cx - 4, cy + 6), p);
        break;

      case 'travel_train':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 9, cy - 11, cx + 9, cy + 9),
                const Radius.circular(4)),
            p);
        canvas.drawLine(Offset(cx - 9, cy - 3), Offset(cx + 9, cy - 3), p);
        canvas.drawCircle(Offset(cx - 5, cy + 5), 2, pf);
        canvas.drawCircle(Offset(cx + 5, cy + 5), 2, pf);
        canvas.drawLine(Offset(cx - 3, cy - 7), Offset(cx - 3, cy - 3), p);
        canvas.drawLine(Offset(cx + 3, cy - 7), Offset(cx + 3, cy - 3), p);
        break;

      case 'travel_bus':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 11, cy - 8, cx + 11, cy + 8),
                const Radius.circular(3)),
            p);
        canvas.drawLine(Offset(cx - 11, cy - 1), Offset(cx + 11, cy - 1), p);
        canvas.drawCircle(Offset(cx - 6, cy + 5), 2.5, pf);
        canvas.drawCircle(Offset(cx + 6, cy + 5), 2.5, pf);
        canvas.drawLine(Offset(cx - 7, cy - 5), Offset(cx - 1, cy - 5), p);
        canvas.drawLine(Offset(cx + 1, cy - 5), Offset(cx + 7, cy - 5), p);
        break;

      case 'travel_bike':
        canvas.drawCircle(Offset(cx - 7, cy + 4), 5, p);
        canvas.drawCircle(Offset(cx + 7, cy + 4), 5, p);
        final path = Path();
        path.moveTo(cx - 7, cy + 4);
        path.lineTo(cx - 2, cy - 4);
        path.lineTo(cx + 7, cy + 4);
        canvas.drawPath(path, p);
        canvas.drawLine(Offset(cx - 2, cy - 4), Offset(cx + 3, cy - 8), p);
        canvas.drawLine(Offset(cx + 1, cy - 8), Offset(cx + 5, cy - 8), p);
        break;

      case 'shopping':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 10, cy - 6, cx + 10, cy + 11),
                const Radius.circular(3)),
            p);
        final handle = Path();
        handle.moveTo(cx - 5, cy - 6);
        handle.quadraticBezierTo(cx - 5, cy - 13, cx, cy - 13);
        handle.quadraticBezierTo(cx + 5, cy - 13, cx + 5, cy - 6);
        canvas.drawPath(handle, p);
        break;

      case 'festival':
        canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy + 8), p);
        for (int i = 0; i < 6; i++) {
          final angle = i * 3.14159 / 3;
          canvas.drawLine(
            Offset(cx, cy - 4),
            Offset(cx + 10 * _cos(angle), cy - 4 + 10 * _sin(angle)),
            p..strokeWidth = 1.5,
          );
        }
        p.strokeWidth = 2.0;
        canvas.drawCircle(Offset(cx, cy - 4), 3, pf);
        break;

      case 'food':
        canvas.drawLine(Offset(cx - 6, cy - 10), Offset(cx - 6, cy + 10), p);
        canvas.drawArc(
            Rect.fromCenter(
                center: Offset(cx - 6, cy - 4), width: 10, height: 8),
            -1.57, 3.14, false, p);
        canvas.drawLine(Offset(cx + 4, cy - 10), Offset(cx + 4, cy + 10), p);
        canvas.drawLine(Offset(cx + 8, cy - 10), Offset(cx + 8, cy + 10), p);
        canvas.drawLine(Offset(cx + 4, cy - 2), Offset(cx + 8, cy - 2), p);
        break;

      case 'education':
        final book = Path();
        book.moveTo(cx, cy - 10);
        book.lineTo(cx - 11, cy - 7);
        book.lineTo(cx - 11, cy + 10);
        book.lineTo(cx, cy + 7);
        book.close();
        canvas.drawPath(book, p);
        final book2 = Path();
        book2.moveTo(cx, cy - 10);
        book2.lineTo(cx + 11, cy - 7);
        book2.lineTo(cx + 11, cy + 10);
        book2.lineTo(cx, cy + 7);
        book2.close();
        canvas.drawPath(book2, p);
        canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy + 7), p);
        break;

      case 'health':
        canvas.drawLine(Offset(cx, cy - 11), Offset(cx, cy + 11), p);
        canvas.drawLine(Offset(cx - 11, cy), Offset(cx + 11, cy), p);
        break;

      case 'music':
        canvas.drawLine(Offset(cx - 2, cy - 10), Offset(cx + 8, cy - 12), p);
        canvas.drawLine(Offset(cx - 2, cy - 10), Offset(cx - 2, cy + 4), p);
        canvas.drawLine(Offset(cx + 8, cy - 12), Offset(cx + 8, cy + 2), p);
        canvas.drawCircle(Offset(cx - 4, cy + 5), 3.5, p);
        canvas.drawCircle(Offset(cx + 6, cy + 3), 3.5, p);
        break;

      case 'gift':
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - 11, cy - 4, cx + 11, cy + 11),
                const Radius.circular(2)),
            p);
        canvas.drawLine(Offset(cx - 11, cy - 4), Offset(cx + 11, cy - 4), p);
        canvas.drawLine(Offset(cx - 11, cy + 1), Offset(cx + 11, cy + 1), p);
        canvas.drawLine(Offset(cx, cy - 4), Offset(cx, cy + 11), p);
        final bow = Path();
        bow.moveTo(cx, cy - 4);
        bow.quadraticBezierTo(cx - 6, cy - 12, cx - 3, cy - 8);
        bow.quadraticBezierTo(cx - 1, cy - 5, cx, cy - 4);
        bow.quadraticBezierTo(cx + 1, cy - 5, cx + 3, cy - 8);
        bow.quadraticBezierTo(cx + 6, cy - 12, cx, cy - 4);
        canvas.drawPath(bow, p);
        break;

      default:
        // General — pin
        canvas.drawCircle(Offset(cx, cy - 6), 6, p);
        canvas.drawLine(Offset(cx, cy), Offset(cx, cy + 10), p);
        canvas.drawCircle(Offset(cx, cy - 6), 2.5, pf);
        break;
    }
  }

  double _cos(double angle) => angle == 0
      ? 1
      : angle == 3.14159
          ? -1
          : angle < 1.6
              ? 0.5
              : -0.5;
  double _sin(double angle) =>
      angle < 0.1 ? 0 : angle < 2 ? 0.866 : angle < 3.5 ? 0.866 : -0.866;

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}